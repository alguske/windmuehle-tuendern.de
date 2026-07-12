# How to update the website (no coding needed)

You can change this website by **describing what you want in plain English** to an
AI coding assistant connected to this repository (OpenAI Codex in the ChatGPT
desktop app, or Claude Code). The assistant edits the files, checks its work, and
opens a *pull request* (a proposed change) for you to approve.

You never touch code. You describe the change, wait for the green check, and click
merge.

## One-time setup

1. In the ChatGPT desktop app, open **Codex** and connect it to this GitHub
   repository (`alguske/windmuehle-tuendern.de`).
2. That is it. The assistant reads the project's own instructions automatically.

## The normal flow

1. **Tell the assistant what you want** (see the recipes below).
2. It opens a **pull request** on GitHub.
3. Wait a minute for the **checks** to run. A green check mark means the site still
   builds and all three languages are in sync. A red X means something is wrong.
4. **Green check → click "Merge".** The live site updates a few minutes later.
5. **Red X → reply to the assistant:** "the check failed, please fix it." Do not
   merge a red pull request.

You do not need to speak German, English and Spanish. The assistant writes all
three languages for you. If it is unsure about a translation, it leaves a note.

## Copy-paste recipes

Change the details in **bold** to fit your case. The more specific you are, the
better the result.

**Add a public guided tour**
> Add a public guided tour on **9 August 2026 at 15:00**, guide **Dirk**. It is a
> normal mill tour, open to everyone.

**Add a private (closed-group) tour**
> Add a private guided tour on **20 June 2026 at 16:00**, guide **Falk**. Do not
> put the group's name anywhere; keep it anonymous.

**Cancel a tour**
> Cancel the tour on **26 July 2026**. Keep it listed but mark it as cancelled.

**Move a tour to another date or time**
> Move the tour on **1 July 2026** to **5 July 2026 at 14:00**.

**Announce an event (concert, talk, etc.)**
> Add an event to the calendar and write a news post: a **benefit concert** by the
> **Frauenchor Tündern** on **29 August 2026 at 17:00** at the
> **St. Christophorus-Kirche in Tündern**. **Entry is free**, proceeds go to the
> windmill. Musical direction: **Adelheid Becker-Foss**. If I have a photo I will
> attach it; otherwise use an existing mill photo.

**Write a news post ("Aktuelles")**
> Write a short news post dated **today** about **the new mill sails being
> installed**. Warm and simple tone. I will attach **2 photos** to use.

**Attach photos**
> Save your photos somewhere on your computer, then tell the assistant where they
> are (for example "the photos are in my Downloads folder, named kirche1.jpg and
> kirche2.jpg"). It will resize and add them.

## Good habits

- Give **full dates** ("29 August 2026"), a **time** ("17:00"), and a **place** if
  it is not the mill.
- For private tours, **never** include family or group names. The assistant knows
  this rule, but say it anyway.
- One request per pull request keeps things easy to review and undo.
- If something looks wrong after merging, tell the assistant "undo the last change"
  and it will open a pull request to revert it.

## Where things live (for the curious)

You do not need this, but if you want to peek: tours are in
`data/fuehrungen.toml`, news posts are in `content/aktuelles/` (and the `en`/`es`
folders), and the full rules for the assistants are in `AGENTS.md`.
