package mcpserver

import (
	"context"
	"errors"
	"log"
	"os"

	"github.com/iosifache/annas-mcp/internal/anna"
	"github.com/modelcontextprotocol/go-sdk/mcp"
	"go.uber.org/zap"
)

type SearchParams struct {
	SearchTerm string `json:"term", mcp:"Term to search for"`
}

type DownloadParams struct {
	BookHash string `json:"hash", mcp:"MD5 hash of the book to download"`
	Title    string `json:"title", mcp:"Book title, used for filename"`
	Format   string `json:"format", mcp:"Book format, for example pdf or epub"`
}

var logger *zap.Logger

func init() {
	var err error
	logger, err = zap.NewProduction()
	if err != nil {
		log.Fatalf("Failed to initialize zap logger: %v", err)
	}
}

func SearchTool(ctx context.Context, cc *mcp.ServerSession, params *mcp.CallToolParamsFor[SearchParams]) (*mcp.CallToolResultFor[any], error) {
	logger.Info("Search command called",
		zap.String("searchTerm", params.Arguments.SearchTerm),
	)

	books, err := anna.FindBook(params.Arguments.SearchTerm)
	if err != nil {
		logger.Error("Search command failed",
			zap.String("searchTerm", params.Arguments.SearchTerm),
			zap.Error(err),
		)
		return nil, err
	}

	bookList := ""
	for _, book := range books {
		bookList += book.String() + "\n\n"
	}

	logger.Info("Search command completed successfully",
		zap.String("searchTerm", params.Arguments.SearchTerm),
		zap.Int("resultsCount", len(books)),
	)

	return &mcp.CallToolResultFor[any]{
		Content:           []mcp.Content{&mcp.TextContent{Text: bookList}},
		StructuredContent: books,
	}, nil
}

func DownloadTool(ctx context.Context, cc *mcp.ServerSession, params *mcp.CallToolParamsFor[DownloadParams]) (*mcp.CallToolResultFor[any], error) {
	logger.Info("Download command called",
		zap.String("bookHash", params.Arguments.BookHash),
		zap.String("title", params.Arguments.Title),
		zap.String("format", params.Arguments.Format),
	)

	secretKey := os.Getenv("ANNAS_SECRET_KEY")
	downloadPath := os.Getenv("ANNAS_DOWNLOAD_PATH")
	if secretKey == "" || downloadPath == "" {
		err := errors.New("ANNAS_SECRET_KEY and ANNAS_DOWNLOAD_PATH environment variables must be set")
		logger.Error("Download command failed",
			zap.String("bookHash", params.Arguments.BookHash),
			zap.Error(err),
		)
		return nil, err
	}

	title := params.Arguments.Title
	format := params.Arguments.Format
	book := &anna.Book{
		Hash:   params.Arguments.BookHash,
		Title:  title,
		Format: format,
	}

	err := book.Download(secretKey, downloadPath)
	if err != nil {
		logger.Error("Download command failed",
			zap.String("bookHash", params.Arguments.BookHash),
			zap.String("downloadPath", downloadPath),
			zap.Error(err),
		)
		return nil, err
	}

	logger.Info("Download command completed successfully",
		zap.String("bookHash", params.Arguments.BookHash),
		zap.String("downloadPath", downloadPath),
	)

	return &mcp.CallToolResultFor[any]{
		Content: []mcp.Content{&mcp.TextContent{
			Text: "Book downloaded successfully to path: " + downloadPath,
		}},
	}, nil
}

func StartServer() {
	defer logger.Sync()

	logger.Info("Starting MCP server",
		zap.String("name", "annas-mcp"),
		zap.String("version", "v0.0.1"),
	)

	server := mcp.NewServer("annas-mcp", "v0.0.1", nil)

	server.AddTools(
		mcp.NewServerTool("search", "Search books", SearchTool, mcp.Input(
			mcp.Property("term", mcp.Description("Term to search for")),
		)),
		mcp.NewServerTool("download", "Download a book by its MD5 hash. Requires ANNAS_SECRET_KEY and ANNAS_DOWNLOAD_PATH environment variables.", DownloadTool, mcp.Input(
			mcp.Property("hash", mcp.Description("MD5 hash of the book to download")),
			mcp.Property("title", mcp.Description("Book title, used for filename")),
			mcp.Property("format", mcp.Description("Book format, for example pdf or epub")),
		)),
	)

	logger.Info("MCP server started successfully")

	if err := server.Run(context.Background(), mcp.NewStdioTransport()); err != nil {
		logger.Fatal("MCP server failed", zap.Error(err))
	}
}
