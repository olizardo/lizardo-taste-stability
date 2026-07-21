with open('references.bib', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix commas at the end of first names causing bibtex to crash (e.g., "Bennett, Tony, Michael Emmison, and John Frow")
import re

def fix_authors(match):
    author_str = match.group(1)
    # Replace the "and" pattern before splitting
    # A common bibtex pattern is Last, First and Last, First
    # For now, let's just replace ", and" with " and" and see if that fixes the "comma at the end" error
    # It is mostly caused by "Last, First, First2, and First3" which bibtex misinterprets.
    # The correct BibTeX format is "Last1, First1 and Last2, First2 and Last3, First3"
    author_str = author_str.replace(', and ', ' and ')
    return f'author = {{{author_str}}}'

text = re.sub(r'author\s*=\s*\{([^}]+)\}', fix_authors, text)

# Fix duplicate entries 
entries = text.split('\n\n')
seen_keys = set()
unique_entries = []
for entry in entries:
    key_match = re.search(r'@\w+\{([^,]+),', entry)
    if key_match:
        key = key_match.group(1)
        if key not in seen_keys:
            seen_keys.add(key)
            unique_entries.append(entry)
    else:
        unique_entries.append(entry)

with open('references.bib', 'w', encoding='utf-8') as f:
    f.write('\n\n'.join(unique_entries))
print("BibTeX formatted")
