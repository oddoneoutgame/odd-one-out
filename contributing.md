# Contributing

- open terminal and navigate to where you cloned the project
- Run this command: `mkdocs serve`
    - If this command doesn't work, try with using your local python installation explicitly as
        in `python3 -m mkdocs serve`.
- The command line will tell you the locally hosted URL of the website. Something like this:
    - `Serving on http://127.0.0.1:8000/`
- Open `http://127.0.0.1:8000/` in your web browser
- Open project files in your preferred text editor. You can edit any files, save them, and the locally hosted site in your browser will automatically update
    - **Note:** If something breaks, you will need to re-fire the command `mkdocs serve` in a terminal window to re-host the site

### Pull Requests

- When contributing, create a branch off of the `main` branch
- Merge your pull request into the `main` branch after it has received one approval
- After your pull request is merged into the `main` branch, the new doc site updated and deployed in five minutes or less

## Styling suggestions and guidelines

### Backticks

- Use backticks for code or file names
    - `Example.kt`
    - `.json`
- When using a code block, use three backticks above and below the code block
- Add the programming language after the third back tick above the code block
- Rendered example:

    ```kotlin
    private val example = "Example code block"
    ```

### Listing Steps

- If you are listing out a set of steps in a single line, separate them with an →
    - **Example:** Charles toolbar → Tools → Import/Export Settings...

### Bolding  

- Use bolding with two `*` to draw extra attention to something
- A common use case for this is bolding items someone needs to click on
    - **Example:** Charles toolbar → **Tools** → **Import/Export Settings...**

### Admonitions  

- Consider adding an **admonition** in certain cases (such as a warning, note, info, etc.)
- [Looking at these examples is the easiest way to get a feel for admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)
- This helps call out something specific, and breaks up a huge wall of text in our docs
    - **Example:**
        - Here is the example syntax for a **warning admonition**:

        ```markdown
        !!! warning
            Sometimes **Throttling** is enabled by default after installing. Double check the **[Throttling](#throttling)** section below
        ```

### Images and Gifs

- There are two main ways to add images / gifs
- **Example 1**
    - Use Example 1 if you need to set the width manually or if you need to set a caption. Prefer this option

    ```markdown
    <figure markdown>
        ![](gifs/open_global_nav_left.gif){ width="700" }
        <figcaption>Example 1</figcaption>
    </figure>
    ```

- **Example 2**

    `![](images/charles_map_local.png)`

### Header Guidelines

- It is important to follow the header guidlines so the **Table of contents** will generate correctly
- Each page uses just one `#` for the top header, and each sub section will add an additional hash mark
- [Click here for a visualization](https://www.markdownguide.org/basic-syntax/#headings)
- Place a space after the `#` in a header, and also add a blank line above and below each header. [Click here for a better visualization](https://www.markdownguide.org/basic-syntax/#heading-best-practices)

### Icons

- Sometimes it may be a nice touch to add a relevant icon
- You can search for the [available bundled icons here](https://squidfunk.github.io/mkdocs-material/reference/icons-emojis/#search)
- Prefer icons without color
- Place the copied icon in markdown and it will render
    - **Example:** `:octicons-pencil-24:`
    - **Note:** Double check to see if the icon you chose renders on our site. Not why why yet, but some do not render properly

### Diagrams

- We do not yet have a consistent standard for creating diagrams on the doc site
- [The site does support Mermaid.js](https://squidfunk.github.io/mkdocs-material/reference/diagrams/?h=merma)
- For larger diagrams we could use Lucid Chart, especially since we already pay for it
