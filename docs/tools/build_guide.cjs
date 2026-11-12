const fs = require('node:fs');
const path = require('node:path');
const docs = path.resolve(__dirname, '..');

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, ch => ({'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;'}[ch]));
}
function inline(value) {
  const tokens = [];
  const hold = html => 'ZZTOKEN' + (tokens.push(html) - 1) + 'ZZ';
  let text = value.replace(/\x60([^\x60]+)\x60/g, (_, code) => hold('<code>' + escapeHtml(code) + '</code>'));
  text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_, title, url) => hold('<a href="' + escapeHtml(url) + '">' + escapeHtml(title) + '</a>'));
  text = text.replace(/https?:\/\/[^\s<>]+/g, url => {
    const target = url.replace(/[.,;:!?)]+$/, '');
    return hold('<a href="' + escapeHtml(target) + '">' + escapeHtml(target) + '</a>') + url.slice(target.length);
  });
  text = escapeHtml(text).replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  return text.replace(/ZZTOKEN(\d+)ZZ/g, (_, index) => tokens[Number(index)]);
}
function slug(text) {
  return text.toLowerCase().replace(/[^a-z0-9 ]/g, '').trim().replace(/\s+/g, '-');
}
function cells(line) {
  return line.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map(cell => cell.trim());
}
function render(markdown) {
  const lines = markdown.replace(/\r\n/g, '\n').split('\n');
  const headings = lines.filter(line => /^## /.test(line)).map(line => ({title: line.slice(3), id: slug(line.slice(3))}));
  const contents = '<nav class="contents" aria-label="Contents"><h2>Contents</h2><ol>' + headings.map(h => '<li><a href="#' + h.id + '">' + escapeHtml(h.title) + '</a></li>').join('') + '</ol></nav>';
  const html = [];
  let i = 0, addedContents = false, codeCount = 0, tableCount = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) { i++; continue; }
    if (/^~~~/.test(line)) {
      const language = line.slice(3).trim() || 'text';
      const code = [];
      i++;
      while (i < lines.length && !/^~~~/.test(lines[i])) code.push(lines[i++]);
      if (i >= lines.length) throw new Error('Unclosed code block');
      i++; codeCount++;
      html.push('<div class="code-block"><div class="code-label"><span>' + escapeHtml(language) + '</span><button type="button" class="copy" aria-label="Copy command block">Copy</button></div><pre><code>' + escapeHtml(code.join('\n')) + '</code></pre></div>');
      continue;
    }
    const heading = line.match(/^(#{1,3}) (.+)$/);
    if (heading) {
      const level = heading[1].length, title = heading[2], id = slug(title);
      if (level === 2 && !addedContents) { html.push(contents); addedContents = true; }
      html.push('<h' + level + ' id="' + id + '">' + escapeHtml(title) + '</h' + level + '>');
      i++; continue;
    }
    if (line.trim().startsWith('|') && i + 1 < lines.length && /^\|[\s:|\-]+\|$/.test(lines[i+1].trim())) {
      const header = cells(line);
      i += 2;
      const rows = [];
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        const row = cells(lines[i++]);
        if (row.length !== header.length) throw new Error('Table column mismatch');
        rows.push('<tr>' + row.map(cell => '<td>' + inline(cell) + '</td>').join('') + '</tr>');
      }
      tableCount++;
      html.push('<div class="table-wrap"><table><thead><tr>' + header.map(cell => '<th scope="col">' + inline(cell) + '</th>').join('') + '</tr></thead><tbody>' + rows.join('') + '</tbody></table></div>');
      continue;
    }
    if (/^- /.test(line)) {
      const items = [];
      while (i < lines.length && /^- /.test(lines[i])) items.push('<li>' + inline(lines[i++].slice(2)) + '</li>');
      html.push('<ul>' + items.join('') + '</ul>');
      continue;
    }
    if (/^\d+\. /.test(line)) {
      const start = Number(line.match(/^(\d+)/)[1]);
      const items = [];
      while (i < lines.length && /^\d+\. /.test(lines[i])) items.push('<li>' + inline(lines[i++].replace(/^\d+\. /, '')) + '</li>');
      html.push('<ol start="' + start + '">' + items.join('') + '</ol>');
      continue;
    }
    const paragraph = [];
    while (i < lines.length && lines[i].trim() && !/^(~~~|#{1,3} |\- |\d+\. |\|)/.test(lines[i])) paragraph.push(lines[i++]);
    if (!paragraph.length) throw new Error('Unsupported block near line ' + (i+1));
    html.push('<p>' + paragraph.map((part, index) => inline(part.trimEnd()) + (index < paragraph.length - 1 ? (part.endsWith('  ') ? '<br>' : ' ') : '')).join('') + '</p>');
  }
  return {body: html.join('\n'), headingCount: headings.length, codeCount, tableCount};
}

const css = [
  ':root{color-scheme:light;--ink:#17251d;--muted:#526057;--green:#285e36;--line:#d7dfd9;--paper:#fff;--bg:#f3f6f3}',
  '*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:85px}body{margin:0;color:var(--ink);background:var(--bg);font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.65}',
  '.toolbar{position:sticky;top:0;z-index:1;background:#17291e;color:#fff;padding:12px 24px;display:flex;gap:16px;align-items:center;justify-content:space-between}.toolbar span{font-size:13px;letter-spacing:.3px}.toolbar button{border:1px solid #a8c7af;background:#fff;color:#17291e;padding:8px 16px;border-radius:7px;font:inherit;font-size:13px;cursor:pointer}.toolbar a{color:#dcf1df;font-size:13px}',
  'main{max-width:1050px;margin:32px auto 56px;background:var(--paper);padding:52px 64px;border:1px solid var(--line);border-radius:12px}h1,h2,h3{color:#000;line-height:1.25;font-weight:700}h1{font-size:34px;letter-spacing:-.9px;margin:0 0 16px}h2{font-size:23px;margin:42px 0 16px;scroll-margin-top:85px}h3{font-size:17px;margin:26px 0 12px}p{margin:0 0 15px}li{margin:7px 0}ul,ol{padding-left:24px;margin:10px 0 20px}strong{font-weight:700}a{color:var(--green);text-underline-offset:3px;overflow-wrap:anywhere}',
  '.contents{margin:30px 0 38px;padding:24px 0}.contents h2{margin-top:0;font-size:20px}.contents ol{display:grid;grid-template-columns:1fr 1fr;gap:8px 28px;list-style:none;padding:0}.contents li{margin:0;line-height:1.4;font-size:13px}.contents a{text-decoration:none}.contents a:hover{text-decoration:underline}',
  'code{font-family:Consolas,"Courier New",monospace;font-size:.9em;background:#eef2ef;padding:2px 5px;border-radius:3px;overflow-wrap:anywhere}.code-block{margin:17px 0 22px;border:1px solid var(--line);border-radius:7px;overflow:hidden;background:#f5f7f5}.code-label{padding:6px 12px;border-bottom:1px solid var(--line);font-size:10px;text-transform:uppercase;letter-spacing:1px;color:var(--muted);display:flex;align-items:center;justify-content:space-between}.copy{border:0;background:transparent;color:var(--green);font:inherit;letter-spacing:0;text-transform:none;font-size:12px;cursor:pointer;padding:2px 8px}pre{margin:0;padding:16px;overflow-x:auto;line-height:1.55;font-size:12px}pre code{padding:0;background:transparent;border-radius:0;white-space:pre;font-size:inherit;overflow-wrap:normal}',
  '.table-wrap{overflow-x:auto;margin:18px 0 24px}table{width:100%;border-collapse:collapse;font-size:13px;line-height:1.5}th,td{border:1px solid #d9d9d9;padding:11px 13px;vertical-align:middle;text-align:left;overflow-wrap:anywhere}th{background:#243a2c;color:#fff;font-weight:700}tbody tr:nth-child(even){background:#f5f7f5}table td:first-child{font-weight:600}table code{background:transparent;padding:0}',
  '.bottom{color:var(--muted);font-size:12px;margin-top:44px;padding-top:16px}.bottom a{margin-right:16px}:focus-visible{outline:3px solid #679273;outline-offset:3px}',
  '@media(max-width:760px){body{font-size:14px}.toolbar{padding:10px 16px}.toolbar span{max-width:180px}main{margin:0;border:0;border-radius:0;padding:30px 20px}h1{font-size:29px}h2{font-size:21px}.contents ol{grid-template-columns:1fr}pre{font-size:11px;padding:12px}th,td{padding:9px;font-size:12px}}',
  '@page{size:A4;margin:17mm 16mm 18mm}@media print{html{scroll-behavior:auto}body{background:#fff;color:#000;font-size:10.5pt;line-height:1.45}.toolbar,.copy,.bottom{display:none}main{max-width:none;margin:0;padding:0;border:0;border-radius:0}h1{font-size:25pt}h2{font-size:17pt;margin-top:24pt;break-after:avoid}h3{font-size:12.5pt;break-after:avoid}p{margin-bottom:9pt;orphans:3;widows:3}a{color:#000}.contents{padding:8pt 0;margin:16pt 0 22pt}.contents ol{gap:5pt 20pt}.contents li{font-size:9pt}.code-block{break-inside:avoid;margin:10pt 0 13pt;border-radius:0}.code-label{padding:4pt 8pt;font-size:7.5pt}pre{padding:9pt;font-size:8.3pt;line-height:1.4;overflow:visible}pre code{white-space:pre-wrap;overflow-wrap:anywhere}.table-wrap{overflow:visible;margin:11pt 0 15pt}table{font-size:8.7pt}thead{display:table-header-group}tr{break-inside:avoid}th,td{padding:7pt 8pt}th{background:#e6ebe7;color:#000}*{-webkit-print-color-adjust:exact;print-color-adjust:exact}}'
].join('\n');

const browserScript = [
  "document.querySelectorAll('.copy').forEach(button=>button.addEventListener('click',async()=>{",
  "const text=button.closest('.code-block').querySelector('pre code').textContent;",
  "try{if(navigator.clipboard&&window.isSecureContext){await navigator.clipboard.writeText(text)}else{const area=document.createElement('textarea');area.value=text;area.style.position='fixed';area.style.opacity='0';document.body.appendChild(area);area.select();if(!document.execCommand('copy'))throw Error('copy');area.remove()}button.textContent='Copied';setTimeout(()=>button.textContent='Copy',1500)}catch{button.textContent='Select text to copy'}}));"
].join('\n');

for (const base of ['PROJECT_GUIDE', 'QUICK_START']) {
  const markdown = fs.readFileSync(path.join(docs, base + '.md'), 'utf8');
  const result = render(markdown);
  const title = base === 'PROJECT_GUIDE' ? 'Community Waste Collection System Guide' : 'Community Waste Quick Start';
  const other = base === 'PROJECT_GUIDE' ? 'QUICK_START.html' : 'PROJECT_GUIDE.html';
  const otherLabel = base === 'PROJECT_GUIDE' ? 'Quick start' : 'Complete guide';
  const html = [
    '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">',
    '<title>' + title + '</title><meta name="description" content="Project setup commands, features, database connections, testing and troubleshooting."><style>' + css + '</style></head><body>',
    '<div class="toolbar"><span>Community Waste Documentation</span><div><a href="' + other + '">' + otherLabel + '</a> &nbsp; <button type="button" onclick="window.print()">Print or save as PDF</button></div></div>',
    '<main>' + result.body + '<div class="bottom"><a href="#' + slug(markdown.split('\n')[0].slice(2)) + '">Back to top</a><a href="' + base + '.md">Markdown source</a></div></main>',
    '<script>' + browserScript + '</script></body></html>'
  ].join('\n');
  const ids = [...html.matchAll(/ id="([^"]+)"/g)].map(match => match[1]);
  const anchors = [...html.matchAll(/href="#([^"]+)"/g)].map(match => match[1]);
  if (new Set(ids).size !== ids.length) throw new Error('Duplicate heading IDs');
  if (anchors.some(anchor => !ids.includes(anchor))) throw new Error('Broken contents link');
  if (html.includes('ZZTOKEN')) throw new Error('Unresolved inline markup');
  if ((markdown.match(/^~~~/gm) || []).length % 2) throw new Error('Unclosed command fence');
  const destination = path.join(docs, base + '.html');
  fs.writeFileSync(destination, html);
  console.log(JSON.stringify({file: base + '.html', sections: result.headingCount, commandBlocks: result.codeCount, tables: result.tableCount, bytes: Buffer.byteLength(html)}));
}

