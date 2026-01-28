document.addEventListener("DOMContentLoaded", () => {
    const quoteText = document.getElementById("quote");
    const authorText = document.getElementById("author");
    const newQuoteBtn = document.getElementById("new-quote-btn");

    const CACHE_KEY_QUOTE = "dailyQuoteText";
    const CACHE_KEY_AUTHOR = "dailyQuoteAuthor";
    const CACHE_KEY_DATE = "dailyQuoteDate";

    const ZEN_TODAY_URL = "https://zenquotes.io/api/today";
    const ZEN_PROXY_URL = `https://api.allorigins.win/raw?url=${encodeURIComponent(ZEN_TODAY_URL)}`;

    const fallbackQuotes = [
        { text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier" },
        { text: "What we do today is what matters most.", author: "Buddha" },
        { text: "Make each day your masterpiece.", author: "John Wooden" },
        { text: "The best way out is always through.", author: "Robert Frost" }
    ];

    let activeController = null;

    function getCstDateKey() {
        const formatter = new Intl.DateTimeFormat("en-CA", {
            timeZone: "America/Chicago",
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
        });
        return formatter.format(new Date());
    }

    function renderQuote(text, author) {
        quoteText.textContent = text ? `"${text}"` : "No quote available.";
        authorText.textContent = author ? `- ${author}` : "";
    }

    function loadCachedQuote() {
        const cachedDate = localStorage.getItem(CACHE_KEY_DATE);
        const cachedText = localStorage.getItem(CACHE_KEY_QUOTE);
        const cachedAuthor = localStorage.getItem(CACHE_KEY_AUTHOR);
        if (cachedDate && cachedText && cachedDate === getCstDateKey()) {
            renderQuote(cachedText, cachedAuthor || "");
            return true;
        }
        return false;
    }

    function saveCachedQuote(text, author) {
        localStorage.setItem(CACHE_KEY_QUOTE, text);
        localStorage.setItem(CACHE_KEY_AUTHOR, author || "");
        localStorage.setItem(CACHE_KEY_DATE, getCstDateKey());
    }

    async function fetchDailyQuote(force = false) {
        if (!force && loadCachedQuote()) {
            return;
        }

        if (activeController) {
            activeController.abort();
        }
        activeController = new AbortController();
        newQuoteBtn.disabled = true;
        newQuoteBtn.textContent = "Loading...";

        try {
            const response = await fetch(ZEN_PROXY_URL, {
                signal: activeController.signal,
                headers: { "Accept": "application/json" },
                cache: "no-store"
            });
            if (!response.ok) {
                throw new Error(`Request failed: ${response.status}`);
            }
            const data = await response.json();
            const first = Array.isArray(data) ? data[0] : null;
            const text = first?.q || "";
            const author = first?.a || "";

            if (!text) {
                throw new Error("Empty quote response");
            }

            saveCachedQuote(text, author);
            renderQuote(text, author);
        } catch (error) {
            const cachedText = localStorage.getItem(CACHE_KEY_QUOTE);
            const cachedAuthor = localStorage.getItem(CACHE_KEY_AUTHOR);
            if (cachedText) {
                renderQuote(cachedText, cachedAuthor || "");
            } else {
                const fallback = fallbackQuotes[Math.floor(Math.random() * fallbackQuotes.length)];
                renderQuote(fallback.text, fallback.author);
            }
            if (error.name !== "AbortError") {
                console.error("Error fetching quote:", error);
            }
        } finally {
            newQuoteBtn.disabled = false;
            newQuoteBtn.textContent = "Refresh Now";
            activeController = null;
        }
    }

    newQuoteBtn.addEventListener("click", () => fetchDailyQuote(true));
    fetchDailyQuote(false);
});

if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("sw.js").catch(() => {});
    });
}
