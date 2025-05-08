import type { CloudFrontHeaders, CloudFrontRequestEvent } from "aws-lambda";
import { readFile, readFileSync } from "node:fs";
import { z } from "zod";
import {
  CognitoIdentityProviderClient,
  GetUserCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { jwtDecode } from "jwt-decode";
import { verify } from "jsonwebtoken";
import getJwksClient from "jwks-rsa";

const cognitoClient = new CognitoIdentityProviderClient({
  region: "eu-west-2",
});

const $AccessToken = z.object({
  client_id: z.string(),
  iss: z.string(),
  token_use: z.string(),
});

const deny = {
  status: "403",
  statusDescription: "Forbidden",
  body: "<h1>Access Denied</h1>",
};

function authFromCookie(headers: CloudFrontHeaders) {
  const cookie = headers.cookie?.[0]?.value;
  const parts = (cookie ?? "").split("; ");
  const kvParts = parts.map((p) => p.split("="));
  const [, t] = kvParts.find(([k]) => k.endsWith("accessToken")) ?? [];
  return t;
}

// function authFromAuthorization(headers: CloudFrontHeaders) {
//   return headers.authorization?.[0]?.value;
// }

const cognitoConfig = z
  .object({
    userPoolId: z.string(),
    userPoolClientId: z.string(),
  })
  .parse(JSON.parse(readFileSync("/var/task/cognito-config.json", "utf8")));

export const handler = async (event: CloudFrontRequestEvent) => {
  const { request } = event.Records[0].cf;

  const [, ownerPath] = request.uri.match(/^\/poc\/([^/]+)\/.*/) ?? [];

  const authorizationToken = authFromCookie(request.headers);

  try {
    if (!authorizationToken) {
      console.warn("no token");
      return deny;
    }

    const issuer = `https://cognito-idp.eu-west-2.amazonaws.com/${cognitoConfig.userPoolId}`;

    const jwksClient = getJwksClient({
      jwksUri: `${issuer}/.well-known/jwks.json`,
    });

    const decodedToken = jwtDecode(authorizationToken, { header: true });

    const { kid } = decodedToken;

    if (!kid) {
      console.warn("Authorization token missing kid");
      return deny;
    }

    const key = await jwksClient.getSigningKey(kid);

    const verifiedToken = verify(authorizationToken, key.getPublicKey(), {
      issuer,
    });

    const { client_id: clientId, token_use: tokenUse } =
      $AccessToken.parse(verifiedToken);

    // client_id claim
    if (clientId !== cognitoConfig.userPoolClientId) {
      console.warn(
        `Token has invalid client ID, expected ${cognitoConfig.userPoolClientId} but received ${clientId}`
      );
      return deny;
    }

    // token_use claim
    if (tokenUse !== "access") {
      console.warn(
        `Token has invalid token_use, expected access but received ${tokenUse}`
      );
      return deny;
    }

    // cognito SDK call - this will error if the user has been deleted
    const { Username, UserAttributes } = await cognitoClient.send(
      new GetUserCommand({
        AccessToken: authorizationToken,
      })
    );

    if (!Username || !UserAttributes) {
      console.warn("Missing user");
      return deny;
    }

    const sub = UserAttributes.find(({ Name }) => Name === "sub")?.Value;

    if (!sub) {
      console.warn("Missing user subject");
      return deny;
    }

    if (ownerPath !== sub) {
      console.warn("owner !== sub");
      return deny;
    }

    return request;
  } catch (error) {
    console.error(error);
    return deny;
  }
};
