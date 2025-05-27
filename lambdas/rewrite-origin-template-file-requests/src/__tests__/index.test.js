const { handler } = require("../index");

describe("template file download origin request rewrite", () => {
  test("it strips the leading /templates/files from the request uri forwarded to the origin", () => {
    const event = {
      request: {
        uri: "/templates/files/owner-id/example.txt",
      },
    };

    const response = handler(event);

    expect(response).toEqual(
      expect.objectContaining({
        uri: "/owner-id/example.txt",
      })
    );
  });

  test("it does not modify requests where the uri does not match", () => {
    const event = {
      request: {
        uri: "/foo/bar/owner-id/example.txt",
      },
    };

    const response = handler(event);

    expect(response).toEqual(
      expect.objectContaining({
        uri: "/foo/bar/owner-id/example.txt",
      })
    );
  });
});
