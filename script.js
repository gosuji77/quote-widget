document.addEventListener("DOMContentLoaded", () => {
    const quoteText = document.getElementById("quote");
    const authorText = document.getElementById("author");
    const newQuoteBtn = document.getElementById("new-quote-btn");
    let activeController = null;
    let lastQuote = "";

    async function fetchQuote() {
        if (activeController) {
            activeController.abort();
        }
        activeController = new AbortController();
        newQuoteBtn.disabled = true;
        newQuoteBtn.textContent = "Loading...";

        try {
            let quote = "";
            let author = "";
            for (let attempt = 0; attempt < 2; attempt += 1) {
                const response = await fetch("https://api.quotable.io/random", {
                    signal: activeController.signal,
                    headers: { "Accept": "application/json" }
                });
                if (!response.ok) {
                    throw new Error(`Request failed: ${response.status}`);
                }
                const data = await response.json();
                quote = data.content || "";
                author = data.author || "";
                if (!quote || quote !== lastQuote) {
                    break;
                }
            }
            lastQuote = quote || "";
            quoteText.textContent = quote ? `"${quote}"` : "No quote available.";
            authorText.textContent = author ? `- ${author}` : "";
        } catch (error) {
            if (error.name !== "AbortError") {
                quoteText.textContent = "Failed to fetch a quote.";
                authorText.textContent = "";
                console.error("Error fetching quote:", error);
            }
        } finally {
            newQuoteBtn.disabled = false;
            newQuoteBtn.textContent = "New Quote";
            activeController = null;
        }
    }

    newQuoteBtn.addEventListener("click", fetchQuote);

    fetchQuote();
});

if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("sw.js").catch(() => {});
    });
}
