var EditDisplay;
var Edit;
var Preview;
var Decorator;
function EditInit() {
    EditDisplay = document.getElementById("edit_display");
    Edit = document.getElementById("edit_value");
    Preview = document.getElementById("preview");
    if (EditDisplay == null)
        return;
    Edit.addEventListener('keydown', EditKeyDown, false);
    Edit.addEventListener('input', EditRefresh, false);
    Edit.addEventListener('paste', EditPaste, false);
    var parser = new Parser({
        code: /^```([a-z]+?)?\r?\n[^`]*?\r?\n```\r?\n/,
        inlinecode: /`[^`\n\r]+?`/,
        fileinsert: /<DROPPED FILE>/,
        string: /"(\\.|[^"\r\n])*"/,
        assign: / ([a-z]+?)=/,
        tag: /\<([^ >]+)>?/,
        tagend: />/,
        whitespace: /\s+/,
        newline: /[\n|\r]+/,
        headline3: /^\#\#\#(.+)\r?\n/,
        headline2: /^\#\#(.+)\r?\n/,
        headline: /^\#(.+)\r?\n/,
        bold: /\*\*(.+?)\*\*/,
        link: /\[(.+?)\]\(([^() ]+?)\)/,
        other: /[\S]+?/,
    });
    Decorator = new TextareaDecorator(Edit, EditDisplay, parser);
    EditRefresh();
    Edit.focus();
}
;
function EditKeyDown(e) {
    if (e.keyCode == 9) {
        document.execCommand('insertText', false, '\t');
        e.preventDefault();
        return;
    }
}
function EditPaste(e) {
    var file = e.clipboardData.files[0];
    if (file == null)
        return;
    UploadFile(file);
}
window.addEventListener('keydown', (e) => {
    if (Preview == null)
        return;
    if (e.ctrlKey && e.keyCode == 32) {
        document.getElementById("previewbutton").click();
        e.preventDefault();
        return;
    }
});
function EditPreview(e, realm, title) {
    e.preventDefault();
    var target = e.target;
    var preview = document.getElementById("preview");
    if (preview.classList.contains("shown")) {
        target.classList.remove("active");
        preview.classList.remove("shown");
        return;
    }
    target.classList.add("active");
    preview.classList.add("shown");
    fetch("/api/page/preview", { method: 'POST', headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' }, body: JSON.stringify({ text: Edit.value, realm: realm, title: title }) })
        .then(r => r.json())
        .then(json => {
        preview.children[1].innerHTML = json.html;
        preview.children[0].innerText = json.title;
    })
        .catch(() => { });
    return false;
}
function EditRefresh() {
    Edit.style.height = "5px";
    var th = Edit.scrollHeight;
    Edit.style.height = th + "px";
    Decorator.update();
}
function CategoryChanged(e) {
    var val = e.target.value;
    var tag = "<cat>" + val + "</cat>";
    var value = Edit.value.replace(/\<cat\>(.*?)\<\/cat\>/, tag);
    if (!value.includes(tag)) {
        value = tag + "\n" + value;
    }
    Edit.value = value;
    EditRefresh();
}
function InsertAtSelection(insert) {
    const start = textarea.selectionStart;
    textarea.setRangeText(insert);
    textarea.selectionStart = textarea.selectionEnd = start;
    textarea.selectionEnd = textarea.selectionStart + insert.length;
    var event = new Event('input', { bubbles: true });
    textarea.dispatchEvent(event);
}
function ReplaceInSelection(replace, withvalue) {
    var i = textarea.value.indexOf(replace);
    console.log(i);
    textarea.value = textarea.value.replace(replace, withvalue);
    textarea.selectionStart = i + withvalue.length;
    textarea.selectionEnd = i + withvalue.length;
    var event = new Event('input', { bubbles: true });
    textarea.dispatchEvent(event);
}
function OnFileDropped(e) {
    if (e.dataTransfer.files.length != 1)
        return;
    e.preventDefault();
    var dt = e.dataTransfer;
    var file = dt.files[0];
    UploadFile(file);
}
function UploadFile(file) {
    var formData = new FormData();
    formData.append('files', file, file.name);
    fetch("/api/files/", { method: 'POST', body: formData })
        .then(r => r.json())
        .then(json => InsertAtSelection(json.code))
        .catch(() => { });
}
const FileInsertTag = "<DROPPED FILE>";
function OnHoverStart(e, event) {
    console.log(event);
    if (event.dataTransfer.types[0] != "Files")
        return;
    if (e.classList.contains('dropping'))
        return;
    e.classList.add('dropping');
    textarea.focus();
    InsertAtSelection(FileInsertTag);
    textarea.selectionEnd = textarea.selectionStart;
}
function OnHoverStop(e, event) {
    if (!e.classList.contains('dropping'))
        return;
    e.classList.remove('dropping');
    ReplaceInSelection(FileInsertTag, "");
}
function InstallFileUpload() {
    textarea = document.getElementById("edit_value");
    var drope = textarea;
    textarea.addEventListener('dragenter', e => OnHoverStart(drope, e), false);
    textarea.addEventListener('dragleave', e => OnHoverStop(drope, e), false);
    textarea.addEventListener('drop', e => OnHoverStop(drope, e), false);
    drope.addEventListener('drop', OnFileDropped, false);
    textarea.addEventListener('select', console.log, false);
    textarea.addEventListener('select', console.log, false);
}
class Navigate {
    static Init() {
        this.pageContent = document.getElementById("pagecontent");
        this.pageTitle = document.getElementById("pagetitle");
        this.pageLinks = document.getElementById("pagelinks");
        this.pageFooter = document.getElementById("pagefooter");
        this.sideBar = document.getElementById("sidebar");
    }
    static ToPage(address, push = true) {
        this.Init();
        if (this.pageContent == null)
            return true;
        if (this.cache[address] != null) {
            window.scrollTo(0, 0);
            this.UpdatePage(this.cache[address]);
            this.pageContent.parentElement.classList.remove("loading");
        }
        else {
            this.pageContent.parentElement.classList.add("loading");
            fetch(address + "?format=json", { method: 'GET' })
                .then(r => r.json())
                .then(json => {
                this.cache[address] = json;
                window.scrollTo(0, 0);
                this.UpdatePage(json);
                this.pageContent.parentElement.classList.remove("loading");
            })
                .catch(() => { });
        }
        if (push) {
            history.pushState({}, "", address);
        }
        this.UpdateSidebar();
        return false;
    }
    static UpdatePage(json) {
        this.pageContent.innerHTML = json.html;
        this.pageTitle.innerText = json.title;
        this.pageFooter.innerHTML = json.footer;
        this.pageLinks.innerHTML = "";
        var siteTitle = document.title.substring(document.title.lastIndexOf(" - "));
        document.title = json.title + siteTitle;
        for (var j = 0; j < json.pageLinks.length; j++) {
            var b = json.pageLinks[j];
            var li = document.createElement("li");
            var a = document.createElement("a");
            a.text = b.label;
            a.href = b.url;
            var icon = document.createElement("i");
            icon.classList.add("mdi");
            icon.classList.add("mdi-" + b.icon);
            if (j == 0) {
                a.classList.add("active");
            }
            a.prepend(icon);
            li.appendChild(a);
            this.pageLinks.appendChild(li);
        }
        this.InstallLinks(this.pageContent);
    }
    static UpdateSidebar() {
        var links = this.sideBar.getElementsByTagName("a");
        for (var i = 0; i < links.length; i++) {
            var a = links[i];
            a.classList.remove("active");
            if (a.href == location.href) {
                a.classList.add("active");
                var parent = a.parentElement;
                while (parent != null) {
                    if (parent.tagName == "DETAILS") {
                        var d = parent;
                        d.open = true;
                    }
                    parent = parent.parentElement;
                }
            }
        }
        var details = this.sideBar.getElementsByTagName("details");
        for (var i = 0; i < details.length; i++) {
            a.classList.remove("active");
        }
    }
    static OnNavigated(event) {
        if (document.location.href.indexOf("#") > 0)
            return;
        this.ToPage(document.location.href, false);
    }
    static InstallLinks(element) {
        var links = element.getElementsByTagName("a");
        var thisHost = window.location.host;
        for (let i = 0; i < links.length; i++) {
            var a = links[i];
            if (a.host != thisHost)
                continue;
            let val = a.getAttribute("href");
            if (val == null || val == '')
                continue;
            if (val.indexOf('#') >= 0 || val.indexOf('~') >= 0)
                continue;
            a.onclick = e => Navigate.ToPage(val);
        }
    }
    static Install() {
        this.Init();
        window.onpopstate = e => this.OnNavigated(e);
        if (this.pageContent == null)
            return true;
        this.InstallLinks(this.pageContent);
        this.InstallLinks(this.sideBar);
    }
}
Navigate.cache = {};
class Parser {
    constructor(rules) {
        this.parseRE = null;
        this.ruleSrc = [];
        this.ruleMap = {};
        this.add(rules);
    }
    add(rules) {
        for (var rule in rules) {
            var s = rules[rule].source;
            this.ruleSrc.push(s);
            this.ruleMap[rule] = new RegExp('^(' + s + ')$', "i");
        }
        this.parseRE = new RegExp(this.ruleSrc.join('|'), 'gmi');
    }
    ;
    tokenize(input) {
        return input.match(this.parseRE);
    }
    ;
    identify(token) {
        for (var rule in this.ruleMap) {
            if (this.ruleMap[rule].test(token)) {
                return rule;
            }
        }
    }
    ;
}
;
class TextareaDecorator {
    constructor(textarea, display, parser) {
        this.input = textarea;
        this.output = display;
        this.parser = parser;
    }
    color(input, output, parser) {
        var oldTokens = output.childNodes;
        var newTokens = parser.tokenize(input);
        var firstDiff, lastDiffNew, lastDiffOld;
        for (firstDiff = 0; firstDiff < newTokens.length && firstDiff < oldTokens.length; firstDiff++)
            if (newTokens[firstDiff] !== oldTokens[firstDiff].textContent)
                break;
        while (newTokens.length < oldTokens.length)
            output.removeChild(oldTokens[firstDiff]);
        for (lastDiffNew = newTokens.length - 1, lastDiffOld = oldTokens.length - 1; firstDiff < lastDiffOld; lastDiffNew--, lastDiffOld--)
            if (newTokens[lastDiffNew] !== oldTokens[lastDiffOld].textContent)
                break;
        for (; firstDiff <= lastDiffOld; firstDiff++) {
            oldTokens[firstDiff].className = parser.identify(newTokens[firstDiff]);
            oldTokens[firstDiff].textContent = oldTokens[firstDiff].innerText = newTokens[firstDiff];
        }
        for (var insertionPt = oldTokens[firstDiff] || null; firstDiff <= lastDiffNew; firstDiff++) {
            var span = document.createElement("span");
            span.className = parser.identify(newTokens[firstDiff]);
            span.textContent = span.innerText = newTokens[firstDiff];
            output.insertBefore(span, insertionPt);
        }
    }
    ;
    update() {
        var input = textarea.value;
        if (input) {
            this.color(input, this.output, this.parser);
        }
        else {
            this.output.innerHTML = '';
        }
    }
}
function ToggleClass(element, classname) {
    var e = document.getElementById(element);
    if (e.classList.contains(classname))
        e.classList.remove(classname);
    else
        e.classList.add(classname);
}
var SearchInput;
var SearchResults;
var SidebarContents;
var MaxResultCount = 200;
var ResultCount = 0;
function InitSearch() {
    SearchInput = document.getElementById("search");
    SearchResults = document.getElementById("searchresults");
    SidebarContents = document.getElementById("contents");
    SearchInput.addEventListener("input", e => UpdateSearch());
}
window.addEventListener('keydown', (e) => {
    if (e.keyCode != 191)
        return;
    if (document.activeElement.tagName == "INPUT")
        return;
    if (document.activeElement.tagName == "TEXTAREA")
        return;
    SearchInput.focus();
    SearchInput.value = "";
    e.preventDefault();
});
function UpdateSearch(limitResults = true) {
    if (limitResults)
        MaxResultCount = 100;
    else
        MaxResultCount = 2000;
    var child = SearchResults.lastElementChild;
    while (child) {
        SearchResults.removeChild(child);
        child = SearchResults.lastElementChild;
    }
    var string = SearchInput.value;
    if (string.length < 1) {
        SidebarContents.classList.remove("searching");
        SearchResults.classList.remove("searching");
        var sidebar = document.getElementById("sidebar");
        var active = sidebar.getElementsByClassName("active");
        if (active.length == 1) {
            active[0].scrollIntoView({ block: "center" });
        }
        return;
    }
    SidebarContents.classList.add("searching");
    SearchResults.classList.add("searching");
    ResultCount = 0;
    Titles = [];
    TitleCount = 0;
    SectionHeader = null;
    var parts = string.split(' ');
    var q = "";
    for (var i in parts) {
        if (parts[i].length < 1)
            continue;
        var t = parts[i].replace(/([^a-zA-Z0-9_-])/g, "\\$1");
        q += ".*(" + t + ")";
    }
    q += ".*";
    var regex = new RegExp(q, 'gi');
    SearchRecursive(regex, SidebarContents);
    if (limitResults && ResultCount > MaxResultCount) {
        var moreresults = document.createElement('a');
        moreresults.href = "#";
        moreresults.classList.add('noresults');
        moreresults.innerHTML = (ResultCount - 100) + ' more results - show more?';
        moreresults.onclick = (e) => { UpdateSearch(false); return false; };
        SearchResults.append(moreresults);
    }
    if (SearchResults.children.length == 0) {
        var noresults = document.createElement('span');
        noresults.classList.add('noresults');
        noresults.innerText = 'no results';
        SearchResults.appendChild(noresults);
    }
}
var SectionHeader;
var TitleCount = 0;
var Titles = [];
function SearchRecursive(str, el) {
    var title = null;
    if (el.children.length > 0 && el.children[0].tagName == "SUMMARY") {
        title = el.children[0].children[0];
        Titles.push(title);
        TitleCount++;
    }
    var children = el.children;
    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        if (child.className == "sectionheader")
            SectionHeader = child;
        if (child.tagName == "A") {
            if (child.parentElement.tagName == "SUMMARY")
                continue;
            var txt = child.getAttribute("search");
            if (txt != null) {
                var found = txt.match(str);
                if (found) {
                    if (ResultCount < MaxResultCount) {
                        AddSearchTitle();
                        var copy = child.cloneNode(true);
                        copy.onclick = e => Navigate.ToPage(copy.href, true);
                        copy.classList.add("node" + TitleCount);
                        SearchResults.appendChild(copy);
                    }
                    ResultCount++;
                }
            }
        }
        SearchRecursive(str, child);
    }
    if (title != null) {
        TitleCount--;
        if (Titles[Titles.length - 1] == title) {
            Titles.pop();
        }
    }
}
function AddSearchTitle() {
    if (Titles.length == 0)
        return;
    if (SectionHeader != null) {
        var copy = SectionHeader.cloneNode(true);
        SearchResults.appendChild(copy);
        SectionHeader = null;
    }
    for (var i = 0; i < Titles.length; i++) {
        var cpy = Titles[i].cloneNode(true);
        cpy.onclick = e => Navigate.ToPage(cpy.href, true);
        cpy.className = "node" + ((TitleCount - Titles.length) + i);
        SearchResults.appendChild(cpy);
    }
    Titles = [];
}
