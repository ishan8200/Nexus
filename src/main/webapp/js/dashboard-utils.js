/**
 * Global search and sort utilities for Nexus Dashboards
 */

function searchTable(inputId, tableId) {
    // Keep this for backward compatibility if needed, but we will mostly use serverSideSearch
    const input = document.getElementById(inputId);
    const filter = input.value.toLowerCase();
    const table = document.getElementById(tableId);
    if (!table) return;
    const tbody = table.querySelector("tbody");
    if (!tbody) return;
    const rows = tbody.getElementsByTagName("tr");

    for (let i = 0; i < rows.length; i++) {
        if (rows[i].cells.length === 1 && rows[i].cells[0].getAttribute("colspan")) {
            continue;
        }
        const text = rows[i].textContent.toLowerCase();
        rows[i].style.display = text.includes(filter) ? "" : "none";
    }
}

function serverSideSearch(paramName, value) {
    const url = new URL(window.location.href);
    if (value && value.trim() !== "") {
        url.searchParams.set(paramName, value.trim());
    } else {
        url.searchParams.delete(paramName);
    }
    window.location.href = url.toString();
}

function serverSideSort(sortByParam, sortByValue, sortDirParam) {
    const url = new URL(window.location.href);
    const currentSortBy = url.searchParams.get(sortByParam);
    const currentSortDir = url.searchParams.get(sortDirParam) || 'ASC';
    
    let newDir = 'ASC';
    if (currentSortBy === sortByValue) {
        newDir = (currentSortDir === 'ASC') ? 'DESC' : 'ASC';
    }
    
    url.searchParams.set(sortByParam, sortByValue);
    url.searchParams.set(sortDirParam, newDir);
    window.location.href = url.toString();
}

function searchCards(inputId, containerId, cardSelector) {
    const input = document.getElementById(inputId);
    const filter = input.value.toLowerCase();
    const container = document.getElementById(containerId);
    if (!container) return;
    const cards = container.querySelectorAll(cardSelector);

    cards.forEach(card => {
        const text = card.textContent.toLowerCase();
        card.style.display = text.includes(filter) ? "" : "none";
    });
}

function sortTable(tableId, colIndex, type) {
    const table = document.getElementById(tableId);
    if (!table) return;
    const tbody = table.querySelector("tbody");
    if (!tbody) return;
    const rows = Array.from(tbody.querySelectorAll("tr")).filter(row => {
        // Filter out "No data" rows
        return !(row.cells.length === 1 && row.cells[0].getAttribute("colspan"));
    });
    
    if (rows.length === 0) return;

    // Check current sort direction
    const currentDir = table.getAttribute("data-sort-dir") || "none";
    const currentCol = String(table.getAttribute("data-sort-col") || "-1");
    
    let isAsc = true;
    if (currentCol === String(colIndex)) {
        isAsc = currentDir !== "asc";
    }
    
    const direction = isAsc ? 1 : -1;
    table.setAttribute("data-sort-dir", isAsc ? "asc" : "desc");
    table.setAttribute("data-sort-col", colIndex);

    // Update UI for sort indicators
    const headers = table.querySelectorAll("th");
    headers.forEach((th, idx) => {
        th.classList.remove("sort-asc", "sort-desc");
        if (idx == colIndex) {
            th.classList.add(isAsc ? "sort-asc" : "sort-desc");
        }
    });

    rows.sort((a, b) => {
        let valA = a.cells[colIndex].innerText.trim();
        let valB = b.cells[colIndex].innerText.trim();
        
        if (type === 'number' || type === 'currency') {
            valA = parseFloat(valA.replace(/[^0-9.-]+/g, "")) || 0;
            valB = parseFloat(valB.replace(/[^0-9.-]+/g, "")) || 0;
        } else if (type === 'date') {
            // Handle common date formats or fallback to string
            const dateA = new Date(valA);
            const dateB = new Date(valB);
            valA = isNaN(dateA.getTime()) ? valA.toLowerCase() : dateA.getTime();
            valB = isNaN(dateB.getTime()) ? valB.toLowerCase() : dateB.getTime();
        } else {
            valA = valA.toLowerCase();
            valB = valB.toLowerCase();
        }
        
        if (valA < valB) return -1 * direction;
        if (valA > valB) return 1 * direction;
        return 0;
    });

    rows.forEach(row => tbody.appendChild(row));
}
