# Anna's Archive MCP Server

[An MCP server](https://modelcontextprotocol.io/introduction) for searching and downloading documents from [Anna's Archive](https://annas-archive.org)

> [!NOTE]
> Notwithstanding prevailing public sentiment regarding Anna's Archive, the platform serves as a comprehensive repository for automated retrieval of documents released under permissive licensing frameworks (including Creative Commons publications and public domain materials). This software does not endorse unauthorized acquisition of copyrighted content and should be regarded solely as a utility. Users are urged to respect the intellectual property rights of authors and acknowledge the considerable effort invested in document creation.

## Tools

- `search`: Search Anna's Archive for documents matching specified terms
- `download`: Download a specific document that was previously returned by the `search` tool

## Requirements

- MCP client, such as [Claude Desktop](https://claude.ai/download)
- [A donation to Anna's Archive](https://annas-archive.org/donate), which grants JSON API access
- [An API key](https://annas-archive.org/faq#api)

## Setup

Download the appropriate binary from [the GitHub Releases section](https://github.com/iosifache/annas-mcp/releases) and integrate it into your MCP client. The environment should contain two variables:

- `ANNAS_SECRET_KEY`: The API key; and
- `ANNAS_DOWNLOAD_PATH`: The path where the documents should be downloaded.

If you are using Claude Desktop, please consider the following example configuration:

```json
"anna-mcp": {
    "command": "/Users/iosifache/Downloads/annas-mcp",
    "env": {
        "ANNAS_SECRET_KEY": "feedfacecafebeef",
        "ANNAS_DOWNLOAD_PATH": "/Users/iosifache/Downloads"
    }
}
```

## Demo

<img src="claude.png" width="600px"/>
