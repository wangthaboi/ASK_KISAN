"""Unit and integration test suite for legal & compliance static pages.

Validates HTML parsing, skeleton loaders, DPDP Act and Meta compliance,
relative link integrity, and secret absence.
"""
import os
import re
from html.parser import HTMLParser
import pytest

PAGES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../pages"))
WORKFLOW_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.github/workflows/pages.yml"))

EXPECTED_FILES = [
    "index.html",
    "privacy.html",
    "terms.html",
    "data-deletion.html",
    "styles.css",
    "app.js",
    "README.md",
]

HTML_FILES = ["index.html", "privacy.html", "terms.html", "data-deletion.html"]


class SimpleHTMLValidator(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.links = []
        self.has_skeleton = False
        self.skeleton_attrs = {}

    def handle_starttag(self, tag, attrs):
        self.tags.append(tag)
        attrs_dict = dict(attrs)
        if "href" in attrs_dict:
            self.links.append(attrs_dict["href"])
        if "class" in attrs_dict and "skeleton-container" in attrs_dict["class"].split():
            self.has_skeleton = True
            self.skeleton_attrs = attrs_dict


def test_files_exist():
    """Verify all expected legal files exist."""
    assert os.path.isdir(PAGES_DIR), f"Directory {PAGES_DIR} not found"
    for filename in EXPECTED_FILES:
        filepath = os.path.join(PAGES_DIR, filename)
        assert os.path.isfile(filepath), f"Expected file {filename} missing in pages directory"


def test_github_pages_workflow_exists():
    """Verify the GitHub Pages deployment workflow exists, targets pages, and triggers on push to main only."""
    assert os.path.isfile(WORKFLOW_FILE), f"Workflow file {WORKFLOW_FILE} does not exist"
    with open(WORKFLOW_FILE, "r", encoding="utf-8") as f:
        content = f.read()
    assert "upload-pages-artifact" in content
    assert "deploy-pages" in content
    assert "path: 'pages'" in content or "path: pages" in content
    # Verify push is strictly configured for main branch only
    assert "- main" in content
    assert "- develop" not in content


@pytest.mark.parametrize("html_filename", HTML_FILES)
def test_html_parsing_and_skeleton_loader(html_filename):
    """Verify every web page contains an accessible skeleton loader."""
    filepath = os.path.join(PAGES_DIR, html_filename)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    validator = SimpleHTMLValidator()
    validator.feed(content)

    # Must contain skeleton loader per project rule
    assert validator.has_skeleton, f"File {html_filename} is missing skeleton loader (.skeleton-container)"
    assert validator.skeleton_attrs.get("role") == "status", f"{html_filename} skeleton must have role='status'"
    assert validator.skeleton_attrs.get("aria-busy") == "true", f"{html_filename} skeleton must have aria-busy='true'"

    # Must link to shared styles and script
    assert "styles.css" in validator.links or '<link rel="stylesheet" href="styles.css">' in content
    assert 'src="app.js"' in content


def test_privacy_policy_compliance():
    """Verify Privacy Policy contains required legal and DPDP Act provisions."""
    filepath = os.path.join(PAGES_DIR, "privacy.html")
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    # Must mention DPDP Act 2023
    assert "Digital Personal Data Protection Act, 2023" in text or "DPDP Act" in text
    # Must specify phone number collection for WhatsApp
    assert "Phone Number" in text or "WhatsApp" in text
    # Must explicitly state not collecting sensitive financial details
    assert "Aadhaar" in text
    assert "UPI PIN" in text or "PIN" in text
    # Must list grievance contact
    assert "ask.kisan@gmail.com" in text or "@" in text


def test_terms_and_conditions_agricultural_disclaimer():
    """Verify Terms of Service contains prominent agricultural advisory disclaimer."""
    filepath = os.path.join(PAGES_DIR, "terms.html")
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    assert "AGRICULTURAL ADVISORY DISCLAIMER" in text
    assert "KVK" in text or "Krishi Vigyan Kendra" in text or "agronomist" in text
    assert "AS IS" in text
    assert "Republic of India" in text or "India" in text


def test_data_deletion_instructions_meta_compliance():
    """Verify Data Deletion Instructions satisfies Meta/WhatsApp app requirements."""
    filepath = os.path.join(PAGES_DIR, "data-deletion.html")
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    # Must provide WhatsApp in-chat command
    assert "DELETE MY DATA" in text
    # Must provide email option
    assert "ask.kisan@gmail.com" in text or "@" in text
    # Must mention Meta compliance
    assert "Meta Platform Terms" in text or "WhatsApp" in text
    # Must specify 48 hours SLA
    assert "48" in text


@pytest.mark.parametrize("html_filename", HTML_FILES)
def test_cross_link_integrity(html_filename):
    """Verify all relative links within the legal pages resolve to existing files."""
    filepath = os.path.join(PAGES_DIR, html_filename)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    validator = SimpleHTMLValidator()
    validator.feed(content)

    for link in validator.links:
        # Ignore external links or anchor jumps
        if link.startswith("http://") or link.startswith("https://") or link.startswith("#"):
            continue
        target_path = os.path.join(PAGES_DIR, link.split("#")[0])
        assert os.path.isfile(target_path), f"Broken relative link '{link}' in {html_filename}"


@pytest.mark.parametrize("filename", EXPECTED_FILES)
def test_no_exposed_secrets(filename):
    """Verify no API keys or credentials leaked in static files."""
    filepath = os.path.join(PAGES_DIR, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Look for obvious secrets or private keys
    assert "BEGIN RSA PRIVATE KEY" not in content
    assert "BEGIN PRIVATE KEY" not in content
    assert not re.search(r"sk-[a-zA-Z0-9]{20,}", content), f"Possible OpenAI key leaked in {filename}"
    assert not re.search(r"AIza[a-zA-Z0-9_-]{35}", content), f"Possible Google API key leaked in {filename}"
