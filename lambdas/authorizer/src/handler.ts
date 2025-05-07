import type { CloudFrontRequestEvent } from "aws-lambda";
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

export const handler = async (event: CloudFrontRequestEvent) => {
  console.log(JSON.stringify(event));

  const { request } = event.Records[0].cf;
  const { headers } = request;

  const [, owner] = request.uri.match(/^\/([a-zA-Z0-9]+)\/.*/) ?? [];

  console.log("owner", owner);

  const cookie = headers.cookie?.[0]?.value;

  console.log("typeof cookie", typeof cookie);

  const parts = (cookie ?? "").split("; ");

  console.log("len", parts.length);

  const kvParts = parts.map((p) => p.split("="));

  const [, t] = kvParts.find(([k]) => k.endsWith("accessToken")) ?? [];

  console.log("t", t);

  try {
    if (!headers?.authorization) {
      console.warn("no headers?.authorization");

      return deny;
    }

    const userPoolId = "eu-west-2_ng27OMYUx";
    const userPoolClientId = "2p8hv75iktpl3kgaej3jboe1ld";
    const authorizationToken = t;

    if (!userPoolId || !userPoolClientId) {
      console.error("Lambda misconfiguration");
      return deny;
    }

    const issuer = `https://cognito-idp.eu-west-2.amazonaws.com/${userPoolId}`;

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
    if (clientId !== userPoolClientId) {
      console.warn(
        `Token has invalid client ID, expected ${userPoolClientId} but received ${clientId}`
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

    if (owner !== sub) {
      console.warn("owner !== sub");
      return deny;
    }

    return request;
  } catch (error) {
    console.error(error);
    return deny;
  }
};
