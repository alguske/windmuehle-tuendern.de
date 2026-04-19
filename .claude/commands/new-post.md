# Create a new blog post

Create a new blog post for the Windmühle Tündern website. Use the blog-post-creator agent to generate the post in all three languages (DE, EN, ES).

The user will provide the topic. Ask for any missing details:
- What is the post about?
- What date should it have? (default: today)
- Are there images to include? (paths in `static/imgs/`)

Create files in:
- `content/aktuelles/YYYY-MM-DD-slug.md`
- `content/en/aktuelles/YYYY-MM-DD-slug.md`
- `content/es/aktuelles/YYYY-MM-DD-slug.md`

Zola derives `page.date` from the filename, so the post frontmatter has no `date` field.

After creating the files, run `zola build` to verify they compile without errors.

$ARGUMENTS
