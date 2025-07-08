package anna

type Book struct {
	Language  string
	Format    string
	Size      string
	Title     string
	Publisher string
	Authors   string
	URL       string
	Hash      string
}

type fastDownloadResponse struct {
	DownloadURL string `json:"download_url"`
	Error       string `json:"error"`
}
