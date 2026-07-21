import re

with open('refs.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Split into entries separated by double newlines
raw_entries = [e.strip().replace('\n', ' ') for e in text.split('\n\n') if len(e.strip()) > 20]
if "References" in raw_entries[0]:
    raw_entries = raw_entries[1:]

bib_entries = []
for i, entry in enumerate(raw_entries):
    # Try to parse Author(s). Year. "Title." or Book.
    # We will do a rough heuristic:
    # 1. Match Authors (everything up to a 4-digit year followed by a period)
    # 2. Match Year
    # 3. Rest of string
    
    match = re.match(r'^(.*?)\.?\s+(\d{4}[a-z]?)\.\s+(.*)$', entry)
    if not match:
        # Fallback to generic misc
        key = f"ref{i}"
        bib = f"@misc{{{key},\n  note = {{{entry}}}\n}}"
        bib_entries.append(bib)
        continue
        
    authors = match.group(1).strip()
    year = match.group(2)
    rest = match.group(3).strip()
    
    # Generate key from first author's last name + year
    # Simple split by comma for first author
    first_author = authors.split(',')[0].split(' ')[-1].lower()
    first_author = re.sub(r'[^a-z]', '', first_author)
    key = f"{first_author}{year}"
    
    # Differentiate between article (quotes around title) and book (\emph{Title})
    title_match = re.match(r'^"([^"]+)"\.?\s+(.*)$', rest)
    if title_match:
        title = title_match.group(1).strip()
        tail = title_match.group(2).strip()
        
        # Check if journal or incollection
        if tail.startswith(r'\emph{'):
            # Journal
            journal_match = re.match(r'\\emph\{([^}]+)\}\s*(.*)$', tail)
            if journal_match:
                journal = journal_match.group(1).strip()
                vol_pages = journal_match.group(2).strip()
                
                bib = f"@article{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  title = {{{title}}},\n  journal = {{{journal}}},\n  note = {{{vol_pages}}}\n}}"
            else:
                bib = f"@misc{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  title = {{{title}}},\n  note = {{{tail}}}\n}}"
        elif tail.lower().startswith('pp.') or " in " in tail:
            # In collection
            bib = f"@incollection{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  title = {{{title}}},\n  note = {{{tail}}}\n}}"
        else:
            bib = f"@misc{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  title = {{{title}}},\n  note = {{{tail}}}\n}}"
    else:
        # Book or other
        book_match = re.match(r'\\emph\{([^}]+)\}\.?\s*(.*)$', rest)
        if book_match:
            title = book_match.group(1).strip()
            publisher_info = book_match.group(2).strip()
            bib = f"@book{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  title = {{{title}}},\n  publisher = {{{publisher_info}}}\n}}"
        else:
            bib = f"@misc{{{key},\n  author = {{{authors}}},\n  year = {{{year}}},\n  note = {{{rest}}}\n}}"

    bib_entries.append(bib)

with open('references.bib', 'w', encoding='utf-8') as f:
    f.write('\n\n'.join(bib_entries))
    
print(f"Generated {len(bib_entries)} BibTeX entries.")
