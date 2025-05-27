const { handler } = require("../index");

describe("template file download origin request rewrite", () => {
  test("it strips the leading /templates/files from the request uri forwarded to the origin", () => {
    const cb = jest.fn();
    const event = {
      Records: [
        {
          cf: {
            request: {
              uri: "/templates/files/owner-id/example.txt",
            },
          },
        },
      ],
    };

    handler(event, {}, cb);

    expect(cb).toHaveBeenCalledWith(
      null,
      expect.objectContaining({
        uri: "/owner-id/example.txt",
      })
    );
  });

  test("it does not modify requests where the uri does not match", () => {
    const cb = jest.fn();
    const event = {
      Records: [
        {
          cf: {
            request: {
              uri: "/foo/bar/owner-id/example.txt",
            },
          },
        },
      ],
    };

    handler(event, {}, cb);

    expect(cb).toHaveBeenCalledWith(
      null,
      expect.objectContaining({
        uri: "/foo/bar/owner-id/example.txt",
      })
    );
  });
});
