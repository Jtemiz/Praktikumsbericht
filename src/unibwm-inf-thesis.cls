% Basierend auf der Vorlage des MNM-Teams
% - optimiert für die Arbeit mit gängigen LaTeX-Editoren
% - funktioniert ohne Makefile und Anpassungen der
%   LaTeX-Verzeichnisstruktur
% - verwendet Komaskript für ein (nach europäischen Gepflogenheiten)
%   schöneres Layout
%
% v1, 2007 (Michael Brenner)
% v1.1, 2012 (Michael Brenner)
% v1.2, 2017 (Michael Brenner)
% v1.2.1, 2017 (Benjamin Schnoy)
% v1.3, 2018 (Michael Grabatin)
% v1.4, 2022 (Daniela Pöhn)
% v1.4.1, 2022 (Daniela Pöhn)
% Diese Version v1.99, 2022 (Julian Fietkau)
%
% To Do:
% - Externe Dokumentation
% - replacelogo: andere Inhalte als nur Text ermöglichen
% - Lizenzhinweis auf dem Titelblatt, wenn "license"-Option gesetzt?

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{unibwm-inf-thesis}[2022/03/12, Abschlussarbeitstemplate, Universitaet der Bundeswehr Muenchen]

% =========== Dokumentklasse auf der wir aufbauen ===========

% Das Paket typearea wird von den KOMA-Klassen geladen. Wir geben hier
% die Papiergröße auf A4 vor. Per durchgereichte  Klassenoption kann dies
% vom Nutzer überschrieben werden.
\PassOptionsToPackage{paper=a4}{typearea}

% Die Klasse scrbook ist eine gute Grundlage für akademische
% Ausarbeitungen aller Art. Für eine Seminararbeit mag sie in einigen
% Punkten manchmal überdimensioniert wirken wenn es scrartcl auch getan
% hätte, für alles darüber ist die Entscheidung allerdings eindeutig.
\LoadClass[bibliography=totoc,listof=totoc,twoside=false,DIV=12]{scrbook}

% =========== Verarbeitung der Optionen ===========

% Benötigt zum Auslesen von Key-Value-Optionen
\RequirePackage{iftex}
\RequirePackage{ifthen}
\RequirePackage{kvoptions}

\SetupKeyvalOptions{family=UniBwM,prefix=UniBwM@}

% Verpflichtende Angabe: Welche Art von Arbeit ist dieses Dokument?
\DeclareStringOption[]{type}

% Verpflichtende Angabe: Welchen Fortschrittsstatus hat das Dokument?
\DeclareStringOption[]{status}

% Welche Sprache hat das Dokument?
% Fehlt diese Option, wird angenommen dass die Arbeit deutsch ist.
% Anders als bei babel & co. ist die Sprachoption hier "german" und nicht
% etwa "ngerman".
\DeclareStringOption[german]{language}

% UniBwM-Logo auf der Titelseite durch etwas Anderes ersetzen?
% Leer lassen um es ganz auszublenden.
\DeclareStringOption[undefined]{replacelogo}

% Abstand zwischen Absätzen statt Einrückung gewünscht?
\DeclareVoidOption{parskip}{\setlength{\parskip}{.6em}\setlength{\parindent}{0pt}}

% Welches Backend soll für die Bibliografie verwendet werden?
% Zur Wahl stehen BibTeX und BibLaTeX, letzteres optional mit Biber.
\DeclareStringOption[bibtex]{bibengine}

% Welcher Bibliografiestil soll verwendet werden? Abhängig vom Backend
% funktioniert die Auswahl anders: Für BibTeX wird der \bibliographystyle-
% Befehl ausgeführt, BibLaTeX erwartet den Stil als Paketoption.
\DeclareStringOption[]{bibstyle}

% Standardmäßig wird natbib geladen, dies kann über diese Option
% gesteuert werden. Mit dem Wert "skip" wird das Paket gar nicht geladen,
% andere Werte werden als Option durchgereicht. Als Default geben wir
% für natbib numerische Referenzen vor, da dies die Kompatibilität mit
% mehr existierenden bibstyles gewähleistet, wenn BibTeX verwendet wird.
\DeclareStringOption[round]{natbib}

% Abstand zwischen Absätzen statt Einrückung gewünscht?
\newcommand{\@UniBwM@doskipfonts}{false}
\DeclareVoidOption{skipfonts}{\renewcommand{\@UniBwM@doskipfonts}{true}}

% Konfiguration zur Anzeige des Abstracts:
% - totoc: Führe Abstract im Inhaltsverzeichnis auf und setze Überschrift
% - notoc: Abstract nicht im Inhaltsverzeichnis, aber mit Überschrift
% - noheader: Abstract nicht im Inhaltsverzeichnis und ohne Überschrift
% - none: Dokument enthält kein Abstract (keine Prüfung bei status=final)
\DeclareStringOption[notoc]{abstract}

% Wie sollen floats (Abbildungen, Tabellen, Listings etc.) nummeriert
% werden?
% - default: Pro Kapitel in Dissertationen, fortlaufend sonst
% - within: Pro Kapitel
% - without: Fotlaufend
\DeclareStringOption[default]{floatnumbering}

% Alle Optionen, die nicht zu unserer Schnittstelle gehören, werden an
% scrbook weitergereicht.
\DeclareDefaultOption{%
  \ifx\CurrentOptionValue\relax%
  \expandafter\KOMAoptions{\expandafter\CurrentOption}%
  \else%
  \expandafter\KOMAoptions{\CurrentOption=\CurrentOptionValue}%
  \fi%
}

\ProcessKeyvalOptions*

% Prüfe Typ und Status
\ifthenelse{\equal{\UniBwM@type}{}}{
  \ClassError{unibwm-inf-thesis}{Mandatory option undefined: type}{Please provide a value for the mandatory class option "type".}
}{}
\def\@UniBwM@isbachelorormaster{false}
\ifthenelse{\equal{\UniBwM@type}{bachelorthesis}}{\def\@UniBwM@isbachelorormaster{true}}{}
\ifthenelse{\equal{\UniBwM@type}{mastersthesis}}{\def\@UniBwM@isbachelorormaster{true}}{}

\ifthenelse{\equal{\UniBwM@status}{}}{
  \ClassError{unibwm-inf-thesis}{Mandatory option undefined: status}{Please provide a value for the mandatory class option "status".}
}{}
\def\@UniBwM@validstatus{false}
\ifthenelse{\equal{\UniBwM@status}{draft}}{\def\@UniBwM@validstatus{true}}{}
\ifthenelse{\equal{\UniBwM@status}{final}}{\def\@UniBwM@validstatus{true}}{}
\ifthenelse{\equal{\@UniBwM@validstatus}{false}}{\ClassError{unibwm-inf-thesis}{Option "status" must be "draft" or "final"}{The mandatory class option "status" must have the value "draft" or "final".}}{}

% Prüfe Sprache
\ifthenelse{\equal{\UniBwM@language}{german}}
{\def\@languagelist{english,ngerman}}
{\ifthenelse{\equal{\UniBwM@language}{english}}
{\def\@languagelist{ngerman,english}}
{\def\@languagelist{ngerman,english,\UniBwM@language}}}

% Verzichte auf das Laden von natbib, falls gewünscht
\ifthenelse{\not\equal{\UniBwM@natbib}{skip}}{
  \ifthenelse{\equal{\UniBwM@bibengine}{bibtex}}
  {\usepackage[\UniBwM@natbib,sort&compress]{natbib}}
  {\PassOptionsToPackage{apalike}{biblatex}}
}{}

% Lade den Bibliografiestil, falls angegeben
\ifthenelse{\not\equal{\UniBwM@bibstyle}{}}
{\ifthenelse{\equal{\UniBwM@bibengine}{bibtex}}
{}
{\PassOptionsToPackage{style=\UniBwM@bibstyle}{biblatex}}
}{}

% Setze das gewünschte BibLaTeX-Backend
\ifthenelse{\equal{\UniBwM@bibengine}{biblatex}}
{\PassOptionsToPackage{backend=bibtex}{biblatex}}{}
\ifthenelse{\equal{\UniBwM@bibengine}{biblatex+biber}}
{\PassOptionsToPackage{backend=biber}{biblatex}}{}

% Prüfe Bibliografie-Engine
\ifthenelse{\equal{\UniBwM@bibengine}{bibtex}}
{}
{\ifthenelse{\equal{\UniBwM@bibengine}{biblatex}\or\equal{\UniBwM@bibengine}{biblatex+biber}}
{\RequirePackage{biblatex}}
{\ClassError{unibw-inf-thesis}{Invalid value for bibengine option}{The class option "bibengine" must be set to bibtex, biblatex or biblatex+biber.}}}

% Prüfe Abstract-Einstellung
\ifthenelse{\not\(\equal{\UniBwM@abstract}{totoc}\or\equal{\UniBwM@abstract}{notoc}\or\equal{\UniBwM@abstract}{noheader}\or\equal{\UniBwM@abstract}{none}\)}
{\ClassError{unibwm-inf-thesis}{Invalid value for option "abstract"}{The class option "abstract" must have the value "totoc", "notoc" or "noheader".}}{}
\newcounter{@UniBwM@abstractcount}

% Prüfe Einstellung von float-Nummerierung
\ifthenelse{\equal{\UniBwM@floatnumbering}{within}\or\equal{\UniBwM@floatnumbering}{without}\or\equal{\UniBwM@floatnumbering}{default}}{}{\ClassError{unibwm-inf-thesis}{Invalid value for option "floatnumbering"}{The class option "floatnumbering" must have the value "within", "without" or "default".}}

% =========== Pakete ===========

% Kodierung der LaTeX-Eingabedaten in UTF-8. Dies ist in sehr
% aktuellen LaTeX-Versionen inzwischen Standard, wird aber hier aus
% Gründen der Kompatibilität immer noch aufgeführt.
\RequirePackage[utf8]{inputenc}
% Durch das folgende Paket werden in der Ausgabe-PDF Type1-Fonts
% eingesetzt. Das wirkt sich für uns in erster Linie so aus, dass
% die Ausgabe "echte" (copy&paste-bare) Umlaute erhält.
\RequirePackage[T1]{fontenc}
% Innerhalb dieser Klasse wird das folgende Paket benutzt, um je nach
% eingestellter Sprache die enthaltenen Bezeichnungen und Textschnipsel
% anzupassen.
\RequirePackage{iflang}
% Wir verwenden das babel-Paket für Multi-Language-Support und weil es
% besser mit BibLaTeX harmoniert als das ngerman-Paket. Zu beachtende:
% Unterschiede: https://tex.stackexchange.com/questions/72893/
\RequirePackage[\@languagelist]{babel}
% Zur formatierten Anzeige des Datums verwenden wir das folgende Paket.
% Es muss nach babel geladen werden.
\RequirePackage[style=ddmmyyyy,datesep=.]{datetime2}
% Das scrhack-Paket behebt ein paar kleine Probleme bei der Verwendung
% von scrbook und listings sowie setspace in Kombination.
\RequirePackage{scrhack}
% Das folgende Paket stellt den enquote-Befehl bereit, welcher noch mal
% angenehmer für Multi-Language-Kontexte ist als die Anführungszeichen-
% Codes von babel.
\RequirePackage[autostyle=true]{csquotes}
% Wir nutzen das xcolor-Paket für komfortable Farbspezifikationen.
\RequirePackage[dvipsnames]{xcolor}
% Das graphicx-Paket erlaubt das Einfügen von Vektor- und Raster-
% Grafiken in verschiedenen Formaten.
\RequirePackage{graphicx}
% Das tikz-Paket wird hier fest vorausgesetzt, da wir es verwenden um
% das UniBwM-Logo zu zeichnen.
\RequirePackage{tikz}
% Das setspace-Paket erlaubt die Einstellung des dokumentweiten
% 1,5-fachen Zeilenabstandes.
\RequirePackage{setspace}
% Das folgende Paket wird verwendet, um fortlaufende bzw. kapitelweise
% nummerierte floats zu gewährleisten.
\RequirePackage{chngcntr}
% Das booktabs-Paket stellt Befehle zur hochwertigen Formatierung von
% Tabellen bereit. Die Verwendung ist zwar optional, wir wollen aber dazu
% ermuntern.
\RequirePackage{booktabs}
% Lade Pakete mit Schriftarten nur, falls nicht vom Nutzer blockiert.
\ifthenelse{\equal{\@UniBwM@doskipfonts}{false}}{
% Bei Latin Modern handelt es sich um einen aktualisierten Satz von
% Schriftarten, die sich eng an Computer Modern (LaTeX-Standardfont)
% orientieren. Sie sehen insgesamt etwas besser aus und unterstützen
% mehr europäische Sprachen.
  \RequirePackage{lmodern}
% DejaVu Sans Mono ist eine moderne Festbreitenschrift, welche gut für
% Code und Monospace-formatierte Textdaten auf dem Bildschirm oder im
% Druck geeignet ist. Julian hätte lieber Inconsolata gehabt, diese hat
% aber keine Italic-Version dabei und ist deshalb zu eingeschränkt.
  \RequirePackage[scaled=0.85]{DejaVuSansMono}
}{}
% Das microtype-Paket nimmt für den Anwender transparent eine Reihe von
% kleinen typografischen Optimierungen vor.
\RequirePackage{microtype}
% Saubere Formatierung von URLs
\RequirePackage{url}
% Innerhalb dieser Klasse wird das folgende Paket für komfortablere
% Fallunterscheidungen verwendet.
\RequirePackage{xifthen}
% Um interne und externe klickbare Links im Dokument haben zu können,
% laden wir das hyperref-Paket. Die farbigen Rahmen blenden wir durch
% die hidelinks-Option allerdings aus, da aus dem Kontext fast immer
% ersichtlich ist was klickbar ist (URLs, Referenzen, Abbildungen etc).
\RequirePackage[hidelinks]{hyperref}
% Mit dem folgenden Paket versehen wir die Ausgabe-PDF basierend auf
% unseren internen Daten mit extern lesbaren XMP-Metadaten. Diese sind
% in modernen PDF-Viewern sichtbar.
\RequirePackage{hyperxmp}
% Das folgende Paket sorgt dafür, dass interne Verweise auf Abbildungen,
% Tabellen usw. auf den beginn der Abbildung/Tabelle verweisen statt auf
% die Beschreibung.
\RequirePackage[all]{hypcap}

% =========== Konfiguration ===========

% Druckfreundliche Namen des Dokumenttypen ermitteln
\newcommand{\@UniBwM@typename}{}
\ifthenelse{\equal{\UniBwM@type}{bachelorthesis}}{%
  \renewcommand{\@UniBwM@typename}{%
    \IfLanguageName{ngerman}{Bachelorarbeit}{Bachelor thesis}}}{%
  \ifthenelse{\equal{\UniBwM@type}{mastersthesis}}{%
    \renewcommand{\@UniBwM@typename}{%
      \IfLanguageName{ngerman}{Masterarbeit}{Master's thesis}}}{%
    \ifthenelse{\equal{\UniBwM@type}{phdthesis}}{%
      \renewcommand{\@UniBwM@typename}{%
        \IfLanguageName{ngerman}{Dissertation}{Doctoral thesis}}}{%
      \ifthenelse{\equal{\UniBwM@type}{seminarpaper}}{%
        \renewcommand{\@UniBwM@typename}{%
          \IfLanguageName{ngerman}{Seminararbeit}{Seminar paper}}}{\renewcommand{\@UniBwM@typename}{\UniBwM@type}}}}}


% Wir geben einen Standardpfad für Abbildungen vor. Dem Nutzer steht es
% natürlich frei, diesen zu überschreiben.
\graphicspath{{./Abbildungen}}

% Wir stellen das Orange der Universität als Farbe zur späteren
% Verwendung bereit.
\definecolor{UniBwMorange}{RGB}{244,121,32}

% Prüfen der LaTeX-Version. https://tex.stackexchange.com/a/615184
\providecommand\@IfFormatAtLeastTF{\@ifl@t@r\fmtversion}

% Automatisches Erstellen der Titelseite zu Beginn des Dokuments.
% Verwendet die neuen LaTeX-Hooks und fällt auf etoolbox zurück, wenn
% wir uns in einer älteren LaTeX-Umgebung befinden. Der Fallback-Code
% kann irgendwann in Zukunft mal entfernt werden.
% https://tex.stackexchange.com/a/615184
\@IfFormatAtLeastTF{2020-10-01}%
{\AddToHook{begindocument/end}{\frontmatter\maketitle\cleardoublepage}}%
{\RequirePackage{etoolbox}\AfterEndPreamble{\frontmatter\maketitle\cleardoublepage}}
% Analog für die Erklärung am Ende
\ifthenelse{\equal{\@UniBwM@isbachelorormaster}{true}}{%
  \ifthenelse{\equal{\UniBwM@status}{final}}{%
    \AtEndDocument{\cleardoublepage\backmatter\makeaffidavit}}{}}{}

% In dem folgenden "alten" Hook können wir unsere Textformatierung und
% sonstige Tweaks vornehmen, bevor das eigentliche Dokument beginnt.
\AtBeginDocument{
% Unter welcher Open-Access-Lizenz steht das Dokument?
% Wird hier ein in dieser Klasse hinterlegtes Kürzel verwendet, werden
% die PDF-Metadaten automatisch mit den passenden Informationen versehen.
% Stattdessen kann für "license" ein Freitext angegeben und durch die
% Option "licenseurl" ergänzt werden.
  \ifcsname UniBwM@license\endcsname
  \ifthenelse{\equal{\UniBwM@license}{cc-by 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung}{Attribution} 4.0 International (CC BY 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-by-sa 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung - Weitergabe unter gleichen Bedingungen}{Attribution-ShareAlike} 4.0 International (CC BY-SA 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by-sa/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-by-nd 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung - Keine Bearbeitungen}{Attribution-NoDerivatives} 4.0 International (CC BY-ND 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by-nd/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-by-nc 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung - Nicht kommerziell}{Attribution-NonCommercial} 4.0 International (CC BY-NC 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by-nc/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-by-nc-sa 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen}{Attribution-NonCommercial-ShareAlike} 4.0 International (CC BY-NC-SA 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by-nc-sa/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-by-nc-nd 4.0}}{
    \def\UniBwM@license{Creative Commons \IfLanguageName{ngerman}{Namensnennung - Nicht-kommerziell - Keine Bearbeitung}{Attribution-NonCommercial-NoDerivatives} 4.0 International (CC BY-NC-ND 4.0)}
    \def\UniBwM@licenseurl{https://creativecommons.org/licenses/by-nc-nd/4.0/}
  }{}
  \ifthenelse{\equal{\UniBwM@license}{cc-0 1.0}}{
    \def\UniBwM@license{Creative Commons Zero 1.0 \IfLanguageName{ngerman}{Universell}{Universal} (CC0 1.0) Public Domain Dedication}
    \def\UniBwM@licenseurl{https://creativecommons.org/publicdomain/zero/1.0/}
  }{}
  \fi
% Da existierende Counter davon abhängen, welche Pakete geladen worden sind, können wir die Anpassung ers hier vornehmen.
  \ifthenelse{\equal{\UniBwM@floatnumbering}{without}\or\(\equal{\UniBwM@floatnumbering}{default}\and\not\equal{\UniBwM@type}{phdthesis}\)}{
    \counterwithout{figure}{chapter}
    \counterwithout{table}{chapter}
    \@ifpackageloaded{listings}{\lstset{numberbychapter=false}}
  }{}
% Wir setzen unser Dokument im sloppy-Modus, das reduziert übermäßig
% strenge Hinweise auf hboxes/vboxes die nicht perfekt passen und genügt
% allen Qualitätsansprüchen in unserem Bereich immer noch bequem.
  \sloppy
% Wir erhöhen die für Seitenzahlen angesetzte Breite ein wenig. Dies
% verhindert Warnungen bei Seitenzahlen über 100.
  \renewcommand*{\@pnumwidth}{3.0ex}
% Wir setzen URLs in Festbreitenschrift. Das ist in den letzten Jahren
% langsam ein wenig aus der Mode gekommen, so heben sie sich jedoch
% besser vom Rest des Textes ab.
  \urlstyle{tt}
% Wir formatieren unseren Text zur Steigerung der Lesbarkeit mit
%1,5-fachem Zeilenabstand.
  \onehalfspacing
% Wir legen den Titel des Dokuments, welchen wir über eigene Kommandos
% erhalten haben, vorsichtshalber auch in den LaTeX-Titel. Möglicherweise
% vereinfacht das den Umgang mit den Metadaten.
  \ifcsname UniBwM@title\endcsname\title{\UniBwM@title}\fi
% Gleiches gilt für den Autor/die Autoren, hier legen wir eine durch
% Kommata getrennte Liste für die Verwendung vor allem in Metadaten an.
  \ifcsname UniBwM@author\endcsname
  \newcommand{\@UniBwM@authorlist}{%
    \UniBwM@author%
    \ifcsname UniBwM@authorB\endcsname, \UniBwM@authorB\fi%
    \ifcsname UniBwM@authorC\endcsname, \UniBwM@authorC\fi%
    \ifcsname UniBwM@authorD\endcsname, \UniBwM@authorD\fi%
    \ifcsname UniBwM@authorE\endcsname, \UniBwM@authorE\fi%
    \ifcsname UniBwM@authorF\endcsname, \UniBwM@authorF\fi%
  }%
  \fi
  \author{\@UniBwM@authorlist}
% Hier speichern wir die verfügbaren Metadaten via hyperxmp in die
% Ausgabe-PDF.
  \ifcsname UniBwM@title\endcsname\hypersetup{pdftitle={\UniBwM@title}}\fi
  \ifcsname @UniBwM@authorlist\endcsname\hypersetup{pdfauthor={\@UniBwM@authorlist}}\fi
  \ifcsname UniBwM@keywords\endcsname\hypersetup{pdfkeywords={\UniBwM@keywords}}\fi
  \ifthenelse{\equal{\UniBwM@status}{draft}}
  {\hypersetup{pdfsubject={\@UniBwM@typename{} (Zwischenstand), Fakultät für Informatik, Universität der Bundeswehr München}}}
  {\hypersetup{pdfsubject={\@UniBwM@typename{}, Fakultät für Informatik, Universität der Bundeswehr München}}}
  \ifcsname UniBwM@license\endcsname
  \ifthenelse{\not\equal{\UniBwM@license}{}}{
    \hypersetup{pdfcopyright={\IfLanguageName{ngerman}{Diese Arbeit ist unter der folgenden Lizenz veröffentlicht}{This document is published under the following license}: \UniBwM@license}}}{}
  \ifcsname UniBwM@licenseurl\endcsname
  \ifthenelse{\not\equal{\UniBwM@licenseurl}{}}{
    \hypersetup{pdflicenseurl={\UniBwM@licenseurl}}}{}
  \fi
  \fi

% Kleine Anpassung des APA-Stils von BibLaTeX:
  \@ifpackageloaded{biblatex}{
    \ifthenelse{\equal{\UniBwM@bibstyle}{apa}}{
% Etwas weniger Einrückung
      \setlength{\bibhang}{2.5em}
% Etwas Abstand zwischen den Einträgen
      \setlength{\bibitemsep}{.5em}
% Zeige die ISBN an, wenn vorhanden
      \renewbibmacro*{doi+url}{%
        \printfield{isbn}%
        \newunit\newblock
        \iftoggle{bbx:doi}
        {\printfield{doi}%
        \iffieldundef{doi}{}{\renewcommand*{\finentrypunct}{\relax}}}
        {}%
        \newunit\newblock
        \iftoggle{bbx:url}
        {\usebibmacro{url+urldate}%
        \iffieldundef{url}{}{\renewcommand*{\finentrypunct}{\relax}}}
        {}}
    }{}}

% Tweaks für das listings-Paket:
  \@ifpackageloaded{listings}{
% Wir definieren ein paar Listing-Stile, welche frei verwendet werden
% können. Der Standardstil verwendet UniBwM-Farben.
    \lstdefinestyle{UniBwM}{
      keywordstyle=\bfseries\color{UniBwMorange},
      keywordstyle={[2]\itshape\color{UniBwMorange}},
      keywordstyle={[3]\color{UniBwMorange}},
      commentstyle=\itshape\color{gray},
      stringstyle=\color{Blue},
    }
    \lstdefinestyle{ClassicLight}{
      keywordstyle=\bfseries\color{NavyBlue},
      keywordstyle={[2]\bfseries\color{Fuchsia}},
      keywordstyle={[3]\itshape\color{DarkOrchid}},
      commentstyle=\itshape\color{gray},
      stringstyle=\color{ForestGreen},
    }
    \lstdefinestyle{ClassicDark}{
      basicstyle=\linespread{1.1}\ttfamily\color{white},
      backgroundcolor=\color{white!20!black},
      frame=single,
      framesep=.3em,
      framexleftmargin=.5em,
      framexrightmargin=.5em,
      keywordstyle=\bfseries\color{ProcessBlue},
      keywordstyle={[2]\bfseries\color{BurntOrange}},
      keywordstyle={[3]\itshape\color{DarkOrchid}},
      commentstyle=\itshape\color{Periwinkle},
      stringstyle=\color{YellowGreen},
    }
    \lstset{
% Wir gleichen das Aussehen an das von Abbildungen und Tabellen an.
      float=pbt,
      captionpos=b,
      abovecaptionskip=1em,
% Formatiere Text fließend und nicht jedes Zeichen einzeln: Dies macht
% Code zugänglich für Copy&Paste ohne zusätzliche Leerzeichen.
      columns=flexible,
% Keine Hervorhebung von Leerzeichen in Strings
      showstringspaces=false,
% Stelle Code auf die Festbreitenschriftart, damit Zeichen wieder korrekt
% untereinander dargestellt werden, und nehme Listings vom 1,5-fachen
% Zeilenabstand aus.
      basicstyle=\linespread{1.1}\ttfamily,
% Default-Stil
      style=UniBwM,
% Folgende Auflistung ermöglicht die Nutzung der gelisteten Sonderzeichen
% in Listings. Die Unterstützung des listings-Pakets für erweiterte
% Zeichen ist leider noch nicht reibungslos.
      literate=%
        {ä}{{\"a}}1
        {ö}{{\"o}}1
        {ü}{{\"u}}1
        {Ä}{{\"A}}1
        {Ö}{{\"O}}1
        {Ü}{{\"U}}1
        {ß}{{\ss}}2
%
        {á}{{\'a}}1
        {à}{{\`a}}1
        {â}{{\^a}}1
        {ǎ}{{\v{a}}}1
        {ã}{{\~a}}1
        {å}{{\r{a}}}1
        {č}{{\v{c}}}1
        {ç}{{\c{c}}}1
        {ď}{{\v{d}}}1
        {é}{{\'e}}1
        {è}{{\`e}}1
        {ê}{{\^e}}1
        {ě}{{\v{e}}}1
        {ë}{{\"e}}1
        {ẽ}{{\~e}}1
        {e̊}{{\r{e}}}1
        {í}{{\'i}}1
        {ì}{{\`i}}1
        {î}{{\^i}}1
        {ǐ}{{\v{i}}}1
        {ı̈}{{\"i}}1
        {ĩ}{{\~i}}1
        {i̊}{{\r{i}}}1
        {ň}{{\v{n}}}1
        {ñ}{{\~n}}1
        {ó}{{\'o}}1
        {ò}{{\`o}}1
        {ô}{{\^{o}}}1
        {ǒ}{{\v{o}}}1
        {õ}{{\~o}}1
        {o̊}{{\r{o}}}1
        {ř}{{\v{r}}}1
        {š}{{\v{s}}}1
        {ť}{{\v{t}}}1
        {ú}{{\'u}}1
        {ù}{{\`u}}1
        {û}{{\^u}}1
        {ǔ}{{\v{u}}}1
        {ũ}{{\~r}}1
        {ů}{{\r{u}}}1
        {ý}{{\'y}}1
        {ž}{{\v{z}}}1
        {Á}{{\'A}}1
        {À}{{\`A}}1
        {Â}{{\^A}}1
        {Ǎ}{{\v{A}}}1
        {Ã}{{\~A}}1
        {Å}{{\r{A}}}1
        {Č}{{\v{C}}}1
        {Ç}{{\c{C}}}1
        {Ď}{{\v{D}}}1
        {É}{{\'E}}1
        {È}{{\`E}}1
        {Ê}{{\^E}}1
        {Ě}{{\v{E}}}1
        {Ë}{{\"E}}1
        {Ẽ}{{\~E}}1
        {E̊}{{\r{E}}}1
        {Í}{{\'I}}1
        {Ì}{{\`I}}1
        {Î}{{\^I}}1
        {Ǐ}{{\v{I}}}1
        {Ï}{{\"I}}1
        {Ĩ}{{\~I}}1
        {I̊}{{\r{I}}}1
        {Ň}{{\v{N}}}1
        {Ñ}{{\~N}}1
        {Ó}{{\'O}}1
        {Ò}{{\`O}}1
        {Ô}{{\^{O}}}1
        {Ǒ}{{\v{O}}}1
        {Õ}{{\~O}}1
        {O̊}{{\r{O}}}1
        {Ř}{{\v{R}}}1
        {Š}{{\v{S}}}1
        {Ť}{{\v{T}}}1
        {Ú}{{\'U}}1
        {Ù}{{\`U}}1
        {Û}{{\^U}}1
        {Ǔ}{{\v{U}}}1
        {Ũ}{{\~R}}1
        {Ů}{{\r{U}}}1
        {Ý}{{\'Y}}1
        {Ž}{{\v{Z}}}1,
    }
% listings bringt keine Sprachdefinition für JavaScript mit - heute eine
% sehr verbreitete Sprache. Wir liefern deshalb eine zusammengefügte
% Version der Definitionen von Gary Hammock mit.
% https://github.com/ghammock/LaTeX_Listings_JavaScript_ES6 (MIT-Lizenz)
    \lstdefinelanguage{JavaScript}{
      morekeywords=[1]{await, async, break, case, catch, class, const, continue, default, delete, do, else, enum, export, extends, finally, for, from, function, if, implements, import, in, instanceof, let, new, return, static, super, switch, this, throw, try, typeof, var, void, while, with},
% Literals, primitive types, and reference types.
      morekeywords=[2]{false, null, true, boolean, number, undefined, Array, Boolean, Date, Math, Number, String, Object},
% Built-ins.
      morekeywords=[3]{eval, parseInt, parseFloat, escape, unescape},
      sensitive,
      morecomment=[s]{/*}{*/},
      morecomment=[l]//,
      morecomment=[s]{/**}{*/}, % JavaDoc style comments
      morestring=[b]',
      morestring=[b]",
      morestring=[b]`
    }[keywords, comments, strings]
% Anpassung der Überschrift für das Listing-Verzeichnis (Standard ist
% einfach nur "Listings")
    \renewcommand{\lstlistlistingname}{\IfLanguageName{ngerman}{Listing-Verzeichnis}{List of Listings}}
  }{} % Ende: Tweaks für das listings-Paket
% Wir stellen ein paar kurze Befehle für typografisch optimierte gängige
% deutsche Abkürzungen bereit.
  \newcommand{\zB}{z.\,B.}
  \newcommand{\dH}{d.\,h.}
  \newcommand{\ua}{u.\,a.}
  \newcommand{\eV}{e.\,V.}
} % Ende: AtBeginDocument

% Platz für Dinge, die wir erst am Ende machen können/müssen
\AtEndDocument{
% Prüfung der Integritätsbedingung für das Abstract
  \ifthenelse{\equal{\UniBwM@status}{final}}{
    \ifthenelse{\equal{\UniBwM@abstract}{none}}
    {\ifthenelse{\not\equal{\value{@UniBwM@abstractcount}}{0}}{
      \ClassWarning{unibwm-inf-thesis}{Abstract found in document while abstract=none}{The option "abstract" is set to "none", but an abstract was found in the document. Is this intentional?}}{}}
    {
      \ifthenelse{\equal{\value{@UniBwM@abstractcount}}{0}}{
        \ClassError{unibwm-inf-thesis}{No abstract found in document}{This type of document requires an abstract. Set the option "abstract" to "none" to avoid this error message if the omission is deliberate.}}{}
      \ifthenelse{\not\(\equal{\value{@UniBwM@abstractcount}}{0}\or\equal{\value{@UniBwM@abstractcount}}{1}\)}{
        \ClassError{unibwm-inf-thesis}{Multiple abstracts found in document}{This type of document requires exactly one abstract. Having multiple abstracts is a structural error.}}{}
    }
  }{}
} % Ende: AtEndDocument


% =========== Befehle und Umgebungen ===========

% Diese Klasse nimmt an, dass pro Dokument nur ein Abstract gebraucht
% wird, und dass das Abstract allein auf einer Seite steht. Fest
% vorgeschrieben ist das allerdings nicht, falls der Nutzer
% experimentieren möchte.
\newenvironment{abstract}{%
  \stepcounter{@UniBwM@abstractcount}
  \ifthenelse{\equal{\UniBwM@abstract}{totoc}}{%
    \phantomsection%
    \addcontentsline{toc}{chapter}{\IfLanguageName{ngerman}{Kurzfassung}{Abstract}}}{}
  \vspace*{0mm}

  \begin{center}
    \ifthenelse{\equal{\UniBwM@abstract}{noheader}}{\vspace{-5mm}}{\sffamily\bfseries\Large\IfLanguageName{ngerman}{Kurzfassung}{Abstract}}
  \end{center}
  }{
  \vspace*{1cm}
}

% Mit diesen zwei Makros erlauben wir es dem Nutzer, Eckdaten zum
% Dokument zu hinterlegen, auf denen dann der Inhalt von Titelblatt etc.
% basieren.
\newcommand{\setvalue}[2]{
  \ifx\@onlypreamble\@notprerr%
  \ClassError{unibwm-inf-thesis}{setvalue called outside of preamble}{All data values need to be set in the preamble, before the start of the document.}
  \else
  \expandafter\newcommand\csname UniBwM@#1\endcsname{#2}
  \fi
}
% Die folgende Möglichkeit zum nachträglichen Zugriff auf die
% hinterlegten Daten ist für den Nutzer gedacht, um Doppelungen von
% Daten zu reduzieren. Innerhalb dieser Klasse sollte stattdessen direkt
% auf die entsprechenden Makros des Schemas \UniBwM@Bezeichner
% zugegriffen werden.
\newcommand{\getvalue}[1]{%
  \ifcsname UniBwM@#1\endcsname%
  \csname UniBwM@#1\endcsname%
  \fi%
}

\newcommand{\@UniBwM@titlepageauthor}[1]{%
  \begin{minipage}{.45\linewidth}%
    \centering%
    \vspace{8mm}%
    \ifcsname UniBwM@author#1\endcsname%
    \csname UniBwM@author#1\endcsname%
    \else%
    \ifthenelse{\equal{\UniBwM@status}{final}}
    {\ClassError{unibwm-inf-thesis}{Missing mandatody field: author}{The field "author" must be defined to compile a final version.}}
    {\textcolor{red}{Warning: Author not defined!}}%
    \fi\\

    \ifcsname UniBwM@matrnr#1\endcsname%
    \csname UniBwM@matrnr#1\endcsname%
    \else%
    \ifthenelse{\equal{\UniBwM@status}{final}\and\(\equal{\UniBwM@type}{bachelorthesis}\or\equal{\UniBwM@type}{mastersthesis}\)}
    {\ClassError{unibwm-inf-thesis}{Missing mandatory field matrnr}{For a final version of bachelorthesis or mastersthesis, a matriculation number is mandatory.}}{}
    \fi%
  \end{minipage}%
}

\newcommand{\@UniBwM@requireddate}[1]{%
  \ifcsname UniBwM@#1\endcsname%
  \csname UniBwM@#1\endcsname%
  \else%
  \ClassError{unibwm-inf-thesis}{Mandatory date missing: #1}{For the titlepage for document type \UniBwM@type{}, the following date is required: #1}%
  \textbf{??.??.????}%
  \fi%
}

\def\maketitle{
  \begin{center}

    \ifthenelse{\not\equal{\UniBwM@replacelogo}{}}{%
      \ifthenelse{\equal{\UniBwM@replacelogo}{undefined}}
      {\UniBwMlogo}
      {\UniBwM@replacelogo}
      \vspace*{1.5cm}
    }{\vspace*{1cm}}

    \linespread{1.0}
    {\Huge%
    \textbf{\sffamily%
    \ifcsname UniBwM@title\endcsname%
    \UniBwM@title%
    \else%
    \ifthenelse{\equal{\UniBwM@status}{final}}
    {\ClassError{unibwm-inf-thesis}{Missing mandatody field: title}{The field "title" must be defined to compile a final version.}}
    {\textcolor{red}{Warning: Title not defined!}}
    \fi}\\%
    }
    \linespread{1.3}

    \ifthenelse{\equal{\UniBwM@status}{draft}}{
      \vspace{5mm}

      {\Large{}-- \IfLanguageName{ngerman}{Zwischenstand vom}{Draft from}
      \ifcsname UniBwM@versiondate\endcsname%
      \UniBwM@versiondate%
      \else%
      \today%
      \fi
      \ --\\}
    }{}

    \ifthenelse{\equal{\UniBwM@type}{phdthesis}}{}{%
      \vfill

      {\Large\@UniBwM@typename}}{}

    \vspace{5mm}

    {\Large\@UniBwM@titlepageauthor{}%
    \ifcsname UniBwM@authorB\endcsname%
    \hfill\@UniBwM@titlepageauthor{B}%
    \fi
    \ifcsname UniBwM@authorC\endcsname%
    \@UniBwM@titlepageauthor{C}%
    \ifcsname UniBwM@authorD\endcsname%
    \hfill\@UniBwM@titlepageauthor{D}%
    \fi
    \fi
    \ifcsname UniBwM@authorE\endcsname%
    \@UniBwM@titlepageauthor{E}%
    \ifcsname UniBwM@authorF\endcsname%
    \hfill\@UniBwM@titlepageauthor{F}%
    \fi%
    \fi%
    }%

    \vfill

    \ifthenelse{\equal{\UniBwM@type}{seminarpaper}}{%
      \ifcsname UniBwM@seminartitle\endcsname%
      \IfLanguageName{ngerman}{Entstanden im Rahmen von}{Created as part of}:

      \textit{\UniBwM@seminartitle}

      \ifcsname UniBwM@seminarcontext\endcsname%
      \UniBwM@seminarcontext%
      \fi
      \fi
    }{}

    \ifthenelse{\equal{\UniBwM@type}{phdthesis}}{%
  \end{center}

  \noindent\large Vollständiger Abdruck der von der Fakultät für Informatik der Universität der Bundeswehr München zur Erlangung des akademischen Grades eines

  \begin{center}
    \ifcsname UniBwM@degreetitle\endcsname
    \csname UniBwM@degreetitle\endcsname
    \else
    Doktors der Naturwissenschaften (Dr. rer. nat.)
    \fi
  \end{center}

  \noindent genehmigten Dissertation.

  \begin{center}
}{}

\vfill

\begin{large}
  \begin{tabular}{ll}
    \ifcsname UniBwM@examiner\endcsname

    \ifcsname UniBwM@examinerlabel\endcsname%
    \UniBwM@examinerlabel%
    \else%
    \ifcsname UniBwM@examinerB\endcsname%
    \IfLanguageName{ngerman}{\ifthenelse{\equal{\UniBwM@type}{phdthesis}}{Erstgutachter}{Erstprüfer}}{Primary examiner}%
    \else%
    \IfLanguageName{ngerman}{\ifthenelse{\equal{\UniBwM@type}{phdthesis}}{Gutachter}{Prüfer}}{Examiner}%
    \fi%
    \fi%
    : & \UniBwM@examiner \\
    \ifcsname UniBwM@examinerB\endcsname
    \ifcsname UniBwM@examinerBlabel\endcsname%
    \UniBwM@examinerBlabel%
    \else%
    \IfLanguageName{ngerman}{\ifthenelse{\equal{\UniBwM@type}{phdthesis}}{Zweitgutachter}{Zweitprüfer}}{Secondary examiner}%
    \fi%
    : & \UniBwM@examinerB \\
    \ifcsname UniBwM@examinerC\endcsname
    \ifcsname UniBwM@examinerClabel\endcsname%
    \UniBwM@examinerClabel%
    \else%
    \IfLanguageName{ngerman}{\ifthenelse{\equal{\UniBwM@type}{phdthesis}}{Drittgutachter}{Drittprüfer}}{Tertiary examiner}%
    \fi%
    : & \UniBwM@examinerC \\
    \fi
    \fi
    \fi
    \ifcsname UniBwM@advisor\endcsname
    \ifcsname UniBwM@advisorlabel\endcsname%
    \UniBwM@advisorlabel%
    \else%
    \IfLanguageName{ngerman}{Betreuer}{Advisor\ifcsname UniBwM@advisorB\endcsname{}s\fi}%
    \fi%
    : & \UniBwM@advisor \\
    \ifcsname UniBwM@advisorB\endcsname
    & \UniBwM@advisorB \\
    \ifcsname UniBwM@advisorC\endcsname
    & \UniBwM@advisorC \\
    \fi
    \fi
    \fi
% The following has to be wrapped in a macro to avoid causing issues from
% using an ampersand within an ifedfine, root cause not entirely clear.
    \newcommand{\@UniBwm@printdeadline}{%
      \IfLanguageName{ngerman}{Abgabetermin}{Deadline}: & \UniBwM@deadline \\}%
    \ifthenelse{\not\equal{\UniBwM@type}{phdthesis}}{%
      \ifdefined\UniBwM@deadline%
      \@UniBwm@printdeadline%
      \fi}{}
  \end{tabular}
\end{large}

\vfill
\ifthenelse{\equal{\UniBwM@type}{phdthesis}}{%
\end{center}
\large

\noindent\ifthenelse{\equal{\UniBwM@status}{final}}{Die Dissertation wurde am \@UniBwM@requireddate{submissiondate} bei der Universität der Bundeswehr München eingereicht und durch die Fakultät für Informatik am \@UniBwM@requireddate{acceptancedate} angenommen. Die mündliche Prüfung fand am \@UniBwM@requireddate{defensedate} statt.}{\textbf{\sffamily Bei diesem Abdruck der Dissertation handelt es sich nicht um die finale Version.}}}%
{\Large %
Universität der Bundeswehr München\\
Fakultät für Informatik\\
\end{center}
}

\thispagestyle{empty}
}


\newcommand{\@UniBwM@affidavitsignatureline}[1]{
\begin{minipage}{.45\linewidth}
\vspace{2cm}
\centering
\dotfill

#1
\end{minipage}
}

\newcommand{\makeaffidavit}{
\cleardoublepage
\thispagestyle{empty}

\begin{large}
% Abhängig von der Bezeichnung für die Art der Arbeit können hier
% ungünstige hboxes entstehen, was allerdings vermutlich niemanden
% stört. Deshalb nehmen wir das warnungslos hin.
\hbadness 10000
\vspace*{2cm}

\noindent
\ifcsname UniBwM@authorB\endcsname
\IfLanguageName{ngerman}{Hiermit versichern wir, dass wir die vorliegende Arbeit selbständig verfasst haben, dass keine anderen als die angegebenen Quellen und Hilfsmittel benutzt wurden und dass alle Zitate ordnungsgemäß gekennzeichnet worden sind.}{We hereby certify that we have written this paper independently, that no sources and aids other than those indicated have been used, and that all citations have been properly marked.}
\else
\IfLanguageName{ngerman}{Hiermit versichere ich, dass ich die vorliegende Arbeit selbständig verfasst habe, dass keine anderen als die angegebenen Quellen und Hilfsmittel benutzt wurden und dass alle Zitate ordnungsgemäß gekennzeichnet worden sind.}{I hereby certify that I have written this paper independently, that no sources and aids other than those indicated have been used, and that all citations have been properly marked.}
\fi
\\[1em]

\ifthenelse{\equal{\@UniBwM@isbachelorormaster}{true}}{%
\noindent
\ifcsname UniBwM@authorB\endcsname
\IfLanguageName{ngerman}{Ferner haben wir vom Merkblatt über die Verwendung der \@UniBwM@typename{} Kenntnis genommen und räumen der Universität der Bundeswehr München das einfache Nutzungsrecht an unserer \@UniBwM@typename{}
\ifcsname UniBwM@retainpublicationrights\endcsname
\textbf{nicht}
\fi
ein.}{Furthermore we acknowledge having received the information overview concerning the usage rights regarding the \@UniBwM@typename{}. We
\ifcsname UniBwM@retainpublicationrights\endcsname
do \textbf{not}
\fi
grant Universität der Bundeswehr München the non-exclusive publication rights to our \@UniBwM@typename{}.}
\else
\IfLanguageName{ngerman}{Ferner habe ich vom Merkblatt über die Verwendung der \@UniBwM@typename{} Kenntnis genommen und räume der Universität der Bundeswehr München das einfache Nutzungsrecht an meiner \@UniBwM@typename{}
\ifcsname UniBwM@retainpublicationrights\endcsname
\textbf{nicht}
\fi
ein.}{Furthermore I acknowledge having received the information overview concerning the usage rights regarding the \@UniBwM@typename{}. I
\ifcsname UniBwM@retainpublicationrights\endcsname
do \textbf{not}
\fi
grant Universität der Bundeswehr München the non-exclusive publication rights to my \@UniBwM@typename{}.}
\fi
}{}

\vspace{2cm}

\noindent
Neubiberg, \IfLanguageName{ngerman}{den}{}
\makeatletter%
\ifcsname UniBwM@versiondate\endcsname%
\UniBwM@versiondate%
\else%
\today%
\fi%
\makeatother

\ifcsname UniBwM@authorB\endcsname\relax\else\vspace*{-2cm}\fi
\begin{center}
\makeatletter
\ifcsname UniBwM@authorB\endcsname\relax\else\hfill\fi
\@UniBwM@affidavitsignatureline{\ifcsname UniBwM@author\endcsname%
\UniBwM@author%
\else%
(\IfLanguageName{ngerman}{Unterschrift des Kandidaten}{Candidate's signature})%
\fi}
\ifcsname UniBwM@authorB\endcsname%
\hfill\@UniBwM@affidavitsignatureline{\UniBwM@authorB}%
\fi
\ifcsname UniBwM@authorC\endcsname%
\@UniBwM@affidavitsignatureline{\UniBwM@authorC}%
\ifcsname UniBwM@authorD\endcsname%
\hfill\@UniBwM@affidavitsignatureline{\UniBwM@authorD}%
\fi
\fi
\ifcsname UniBwM@authorE\endcsname%
\@UniBwM@affidavitsignatureline{\UniBwM@authorE}%
\ifcsname UniBwM@authorF\endcsname%
\hfill\@UniBwM@affidavitsignatureline{\UniBwM@authorF}%
\fi
\fi
\makeatother
\end{center}

\end{large}
}

\newcommand{\UniBwMlogo}[1][]{
\let\UniBwM@logoscale\relax
\ifthenelse{\isempty{#1}}{
\newcommand{\@UniBwM@logoscale}{1.0}
}{
\newcommand{\@UniBwM@logoscale}{#1}
}
\makeatletter
\@ifundefinedcolor{UniBwMgray}{\definecolor{UniBwMgray}{RGB}{107,108,114}}{}
\@ifundefinedcolor{UniBwMorange}{\definecolor{UniBwMorange}{RGB}{244,121,32}}{}
\makeatother
\scalebox{\@UniBwM@logoscale}{
\begin{tikzpicture}[y=.06pt,x=.06pt,yscale=-1,xscale=1]
\path[fill=UniBwMgray](260,291)--(222,291)--(187,472)..controls(176,533)and(147,555)..(97,555)..controls(46,555)and(32,530)..(41,483)--(78,291)--(39,291)--(03,481)..controls(-07,540)and(07,587)..(92,587)..controls(165,587)and(211,552)..(225,476)--(260,291)--cycle;
\path[fill=UniBwMgray](476,437)..controls(484,392)and(471,364)..(431,364)..controls(386,364)and(352,408)..(332,453)--(331,453)..controls(346,407)and(352,383)..(354,368)--(317,368)..controls(311,400)and(303,440)..(298,471)--(276,583)--(314,583)--(323,535)..controls(333,481)and(377,397)..(417,397)..controls(437,397)and(443,412)..(436,446)--(410,583)--(448,583)--(476,437)--cycle;
\path[fill=UniBwMgray](617,306)..controls(618,293)and(607,282)..(593,282)..controls(579,282)and(566,294)..(566,308)..controls(565,322)and(575,333)..(589,333)..controls(603,333)and(616,321)..(617,306)--cycle(599,368)--(560,368)--(519,583)--(557,583)--(599,368)--cycle;
\path[fill=UniBwMgray](831,372)--(795,359)--(704,536)--(704,536)..controls(703,523)and(701,508)..(699,494)--(679,368)--(638,368)--(676,583)--(716,583)--(831,372)--cycle;
\path[fill=UniBwMgray](1014,413)..controls(1014,388)and(997,364)..(951,364)..controls(880,364)and(833,434)..(833,517)..controls(833,566)and(856,587)..(906,587)..controls(934,587)and(959,582)..(980,574)--(980,543)..controls(961,551)and(939,555)..(919,555)..controls(884,555)and(873,547)..(873,513)..controls(873,506)and(874,495)..(875,488)..controls(967,485)and(1014,459)..(1014,413)--cycle(976,418)..controls(976,444)and(946,457)..(880,460)..controls(890,424)and(913,394)..(947,394)..controls(964,394)and(976,402)..(976,418)--cycle;
\path[fill=UniBwMgray](1188,364)..controls(1146,357)and(1120,395)..(1096,448)--(1095,447)..controls(1108,410)and(1114,387)..(1117,368)--(1080,368)--(1040,583)--(1078,583)--(1087,535)..controls(1098,475)and(1140,391)..(1180,402)--(1188,364)--cycle;
\path[fill=UniBwMgray](1326,367)..controls(1316,366)and(1305,364)..(1290,364)..controls(1234,364)and(1205,393)..(1205,430)..controls(1205,481)and(1269,487)..(1269,521)..controls(1269,544)and(1250,555)..(1222,555)..controls(1210,555)and(1199,553)..(1187,549)--(1180,584)..controls(1191,586)and(1203,587)..(1217,587)..controls(1278,587)and(1310,553)..(1310,517)..controls(1310,469)and(1244,459)..(1244,425)..controls(1244,407)and(1259,394)..(1287,394)..controls(1298,394)and(1309,395)..(1320,399)--(1326,367)--cycle;
\path[fill=UniBwMgray](1452,306)..controls(1453,293)and(1442,282)..(1428,282)..controls(1414,282)and(1402,294)..(1401,308)..controls(1400,322)and(1411,333)..(1425,333)..controls(1439,333)and(1451,321)..(1452,306)--cycle(1434,368)--(1396,368)--(1355,583)--(1393,583)--(1434,368)--cycle;
\path[fill=UniBwMgray](1611,368)--(1552,368)--(1567,290)--(1527,299)--(1514,368)--(1471,368)--(1465,399)--(1508,399)--(1485,517)..controls(1476,566)and(1488,586)..(1532,586)..controls(1544,586)and(1559,585)..(1572,582)--(1574,550)..controls(1566,552)and(1557,553)..(1545,553)..controls(1523,553)and(1519,544)..(1525,511)--(1546,399)--(1605,399)--(1611,368)--cycle;
\path[fill=UniBwMgray](1823,371)..controls(1803,367)and(1780,365)..(1755,365)..controls(1662,365)and(1621,443)..(1621,522)..controls(1621,567)and(1637,587)..(1669,587)..controls(1721,587)and(1753,529)..(1769,495)--(1770,496)..controls(1757,536)and(1749,564)..(1745,583)--(1783,583)..controls(1792,532)and(1800,491)..(1823,371)--cycle(1780,399)--(1777,417)..controls(1767,468)and(1723,554)..(1682,554)..controls(1669,554)and(1660,543)..(1660,515)..controls(1660,462)and(1685,395)..(1749,395)..controls(1761,395)and(1771,397)..(1780,399)--cycle(1828,299)..controls(1828,287)and(1818,277)..(1805,277)..controls(1792,277)and(1781,287)..(1781,301)..controls(1781,313)and(1791,323)..(1804,323)..controls(1817,323)and(1828,313)..(1828,299)--cycle(1745,299)..controls(1745,287)and(1735,277)..(1722,277)..controls(1709,277)and(1698,287)..(1698,301)..controls(1698,313)and(1708,323)..(1721,323)..controls(1734,323)and(1745,313)..(1745,299)--cycle;
\path[fill=UniBwMgray](1995,368)--(1937,368)--(1952,290)--(1912,299)--(1899,368)--(1855,368)--(1849,399)--(1893,399)--(1870,517)..controls(1861,566)and(1872,586)..(1916,586)..controls(1929,586)and(1944,585)..(1956,582)--(1959,550)..controls(1950,552)and(1941,553)..(1929,553)..controls(1908,553)and(1904,544)..(1910,511)--(1931,399)--(1989,399)--(1995,368)--cycle;
\path[fill=UniBwMorange](3047,291)--(2997,291)--(2900,478)..controls(2890,498)and(2883,513)..(2875,533)--(2874,533)..controls(2874,516)and(2872,496)..(2869,475)--(2844,291)--(2797,291)--(2700,583)--(2741,583)--(2792,418)..controls(2801,390)and(2808,367)..(2814,343)--(2814,343)..controls(2814,361)and(2817,386)..(2820,408)--(2844,583)--(2885,583)--(2982,395)..controls(2992,375)and(3000,357)..(3006,343)--(3007,343)..controls(3005,360)and(3003,383)..(3002,417)--(2993,583)--(3034,583)--(3047,291)--cycle;
\path[fill=UniBwMorange](3303,368)--(3265,368)--(3256,417)..controls(3246,470)and(3202,554)..(3162,554)..controls(3143,554)and(3137,539)..(3143,506)--(3170,368)--(3131,368)--(3104,514)..controls(3095,559)and(3109,587)..(3148,587)..controls(3193,587)and(3227,544)..(3247,498)--(3248,498)..controls(3233,544)and(3228,569)..(3224,583)--(3263,583)--(3303,368)--cycle(3294,299)..controls(3294,287)and(3284,277)..(3271,277)..controls(3258,277)and(3247,287)..(3247,301)..controls(3247,313)and(3257,323)..(3270,323)..controls(3283,323)and(3294,313)..(3294,299)--cycle(3211,299)..controls(3211,287)and(3201,277)..(3188,277)..controls(3175,277)and(3164,287)..(3164,301)..controls(3164,313)and(3174,323)..(3187,323)..controls(3200,323)and(3211,313)..(3211,299)--cycle;
\path[fill=UniBwMorange](3533,437)..controls(3542,392)and(3528,364)..(3488,364)..controls(3444,364)and(3409,408)..(3389,453)--(3388,453)..controls(3403,407)and(3409,383)..(3412,368)--(3374,368)..controls(3369,400)and(3361,440)..(3355,471)--(3334,583)--(3372,583)--(3381,535)..controls(3391,481)and(3435,397)..(3475,397)..controls(3494,397)and(3500,412)..(3494,446)--(3467,583)--(3505,583)--(3533,437)--cycle;
\path[fill=UniBwMorange](3745,371)..controls(3731,367)and(3717,365)..(3699,365)..controls(3622,365)and(3576,434)..(3576,516)..controls(3576,556)and(3595,586)..(3651,586)..controls(3673,586)and(3692,582)..(3708,576)--(3710,542)..controls(3697,548)and(3679,552)..(3662,552)..controls(3624,552)and(3617,529)..(3617,507)..controls(3617,458)and(3642,397)..(3697,397)..controls(3712,397)and(3724,400)..(3736,405)--(3745,371)--cycle;
\path[fill=UniBwMorange](3955,437)..controls(3963,392)and(3950,364)..(3910,364)..controls(3865,364)and(3831,408)..(3810,453)--(3810,453)..controls(3826,406)and(3830,385)..(3834,368)--(3853,268)--(3815,268)--(3755,583)--(3793,583)--(3802,535)..controls(3812,481)and(3856,397)..(3896,397)..controls(3915,397)and(3921,412)..(3915,446)--(3889,583)--(3927,583)--(3955,437)--cycle;
\path[fill=UniBwMorange](4179,413)..controls(4179,388)and(4162,364)..(4116,364)..controls(4045,364)and(3998,434)..(3998,517)..controls(3998,566)and(4021,587)..(4071,587)..controls(4099,587)and(4124,582)..(4144,574)--(4144,543)..controls(4126,551)and(4104,555)..(4084,555)..controls(4049,555)and(4038,547)..(4038,513)..controls(4038,506)and(4039,495)..(4040,488)..controls(4132,485)and(4179,459)..(4179,413)--cycle(4141,418)..controls(4141,444)and(4111,457)..(4045,460)..controls(4055,424)and(4077,394)..(4112,394)..controls(4129,394)and(4141,402)..(4141,418)--cycle;
\path[fill=UniBwMorange](4404,437)..controls(4412,392)and(4399,364)..(4359,364)..controls(4314,364)and(4280,408)..(4260,453)--(4259,453)..controls(4274,407)and(4280,383)..(4283,368)--(4245,368)..controls(4239,400)and(4232,440)..(4226,471)--(4204,583)--(4242,583)--(4252,535)..controls(4261,481)and(4306,397)..(4345,397)..controls(4365,397)and(4371,412)..(4364,446)--(4338,583)--(4376,583)--(4404,437)--cycle;
\path[fill=UniBwMgray](2088,00)--(2069,00)--(2060,49)..controls(2054,49)and(2050,48)..(2045,48)..controls(1998,48)and(1977,87)..(1977,127)..controls(1977,149)and(1986,159)..(2001,159)..controls(2027,159)and(2044,130)..(2051,113)--(2052,114)..controls(2045,134)and(2041,148)..(2040,157)--(2059,157)..controls(2060,148)and(2063,133)..(2066,119)--(2088,00)--cycle(2057,65)--(2055,74)..controls(2050,100)and(2028,143)..(2008,143)..controls(2001,143)and(1997,137)..(1997,123)..controls(1997,97)and(2010,63)..(2042,63)..controls(2048,63)and(2053,64)..(2057,65)--cycle;
\path[fill=UniBwMgray](2185,72)..controls(2185,60)and(2176,48)..(2153,48)..controls(2117,48)and(2094,83)..(2094,124)..controls(2094,149)and(2106,159)..(2130,159)..controls(2144,159)and(2157,157)..(2167,153)--(2167,137)..controls(2158,141)and(2147,143)..(2137,143)..controls(2120,143)and(2114,139)..(2114,122)..controls(2114,119)and(2114,113)..(2115,110)..controls(2161,108)and(2185,95)..(2185,72)--cycle(2165,75)..controls(2165,88)and(2151,94)..(2117,96)..controls(2122,77)and(2134,63)..(2151,63)..controls(2160,63)and(2165,67)..(2165,75)--cycle;
\path[fill=UniBwMgray](2271,48)..controls(2251,44)and(2238,63)..(2226,90)--(2225,89)..controls(2231,71)and(2234,59)..(2236,50)--(2218,50)--(2197,157)--(2216,157)--(2221,133)..controls(2226,103)and(2248,61)..(2268,67)--(2271,48)--cycle;
\path[fill=UniBwMgray](2430,39)..controls(2430,22)and(2417,11)..(2389,11)..controls(2373,11)and(2358,11)..(2348,11)--(2320,157)..controls(2334,157)and(2348,158)..(2357,158)..controls(2398,158)and(2420,135)..(2420,107)..controls(2420,95)and(2412,83)..(2399,81)--(2399,80)..controls(2415,74)and(2430,61)..(2430,39)--cycle(2409,43)..controls(2409,63)and(2391,74)..(2368,74)..controls(2363,74)and(2359,74)..(2355,74)--(2364,27)..controls(2370,27)and(2377,27)..(2384,27)..controls(2404,27)and(2409,33)..(2409,43)--cycle(2400,109)..controls(2400,127)and(2386,142)..(2360,142)..controls(2352,142)and(2346,141)..(2342,141)--(2352,90)..controls(2356,89)and(2363,89)..(2369,89)..controls(2390,89)and(2400,96)..(2400,109)--cycle;
\path[fill=UniBwMgray](2547,50)--(2528,50)--(2523,74)..controls(2518,101)and(2496,143)..(2476,143)..controls(2466,143)and(2463,135)..(2467,119)--(2480,50)--(2461,50)--(2447,123)..controls(2442,145)and(2449,159)..(2469,159)..controls(2492,159)and(2509,138)..(2519,115)--(2519,115)..controls(2512,138)and(2509,150)..(2507,157)--(2526,157)--(2547,50)--cycle;
\path[fill=UniBwMgray](2662,84)..controls(2666,62)and(2659,48)..(2639,48)..controls(2617,48)and(2600,70)..(2590,92)--(2589,92)..controls(2597,69)and(2600,57)..(2601,50)--(2582,50)..controls(2579,66)and(2576,86)..(2573,101)--(2562,157)--(2581,157)--(2585,133)..controls(2590,106)and(2613,64)..(2632,64)..controls(2642,64)and(2645,72)..(2642,89)--(2629,157)--(2648,157)--(2662,84)--cycle;
\path[fill=UniBwMgray](2794,00)--(2775,00)--(2765,49)..controls(2760,49)and(2756,48)..(2750,48)..controls(2703,48)and(2683,87)..(2683,127)..controls(2683,149)and(2691,159)..(2707,159)..controls(2733,159)and(2749,130)..(2757,113)--(2757,114)..controls(2751,134)and(2747,148)..(2745,157)--(2764,157)..controls(2766,148)and(2768,133)..(2771,119)--(2794,00)--cycle(2762,65)--(2761,74)..controls(2756,100)and(2734,143)..(2714,143)..controls(2707,143)and(2703,137)..(2703,123)..controls(2703,97)and(2715,63)..(2747,63)..controls(2753,63)and(2758,64)..(2762,65)--cycle;
\path[fill=UniBwMgray](2890,72)..controls(2890,60)and(2882,48)..(2859,48)..controls(2823,48)and(2800,83)..(2800,124)..controls(2800,149)and(2811,159)..(2836,159)..controls(2850,159)and(2862,157)..(2873,153)--(2873,137)..controls(2864,141)and(2853,143)..(2843,143)..controls(2825,143)and(2819,139)..(2819,122)..controls(2819,119)and(2820,113)..(2821,110)..controls(2867,108)and(2890,95)..(2890,72)--cycle(2871,75)..controls(2871,88)and(2856,94)..(2823,96)..controls(2828,77)and(2839,63)..(2856,63)..controls(2865,63)and(2871,67)..(2871,75)--cycle;
\path[fill=UniBwMgray](2971,49)..controls(2966,49)and(2960,48)..(2953,48)..controls(2925,48)and(2910,62)..(2910,81)..controls(2910,106)and(2942,109)..(2942,126)..controls(2942,138)and(2933,143)..(2919,143)..controls(2913,143)and(2907,142)..(2901,140)--(2898,158)..controls(2903,159)and(2909,159)..(2916,159)..controls(2947,159)and(2963,142)..(2963,124)..controls(2963,100)and(2930,95)..(2930,78)..controls(2930,69)and(2937,63)..(2951,63)..controls(2957,63)and(2962,63)..(2967,65)--(2971,49)--cycle;
\path[fill=UniBwMgray](3148,51)--(3130,46)--(3088,134)--(3088,134)..controls(3088,127)and(3087,115)..(3086,107)--(3078,50)--(3058,50)--(3017,134)--(3017,134)..controls(3017,127)and(3016,117)..(3015,107)--(3010,50)--(2989,50)--(3001,157)--(3022,157)--(3063,75)--(3063,75)..controls(3063,82)and(3064,90)..(3065,96)--(3073,157)--(3095,157)--(3148,51)--cycle;
\path[fill=UniBwMgray](3241,72)..controls(3241,60)and(3232,48)..(3209,48)..controls(3173,48)and(3150,83)..(3150,124)..controls(3150,149)and(3162,159)..(3186,159)..controls(3200,159)and(3213,157)..(3223,153)--(3223,137)..controls(3214,141)and(3203,143)..(3193,143)..controls(3176,143)and(3170,139)..(3170,122)..controls(3170,119)and(3170,113)..(3171,110)..controls(3217,108)and(3241,95)..(3241,72)--cycle(3221,75)..controls(3221,88)and(3207,94)..(3173,96)..controls(3178,77)and(3190,63)..(3207,63)..controls(3215,63)and(3221,67)..(3221,75)--cycle;
\path[fill=UniBwMgray](3353,84)..controls(3357,62)and(3350,48)..(3331,48)..controls(3308,48)and(3291,70)..(3281,92)--(3280,92)..controls(3288,69)and(3291,58)..(3293,50)--(3302,00)--(3283,00)--(3253,157)--(3272,157)--(3277,133)..controls(3282,106)and(3304,64)..(3324,64)..controls(3333,64)and(3336,72)..(3333,89)--(3320,157)--(3339,157)--(3353,84)--cycle;
\path[fill=UniBwMgray](3449,48)..controls(3428,44)and(3415,63)..(3403,90)--(3403,89)..controls(3409,71)and(3412,59)..(3414,50)--(3395,50)--(3375,157)--(3394,157)--(3398,133)..controls(3404,103)and(3425,61)..(3445,67)--(3449,48)--cycle;
\path[fill=UniBwMorange](2441,602)..controls(2438,610)and(2426,613)..(2423,607)..controls(2420,600)and(2418,600)..(2413,596)..controls(2407,591)and(2415,590)..(2415,590)..controls(2414,589)and(2410,587)..(2406,586)..controls(2399,584)and(2400,576)..(2407,575)..controls(2417,575)and(2422,576)..(2430,581)..controls(2436,584)and(2441,586)..(2447,586)..controls(2455,587)and(2454,603)..(2443,603)--(2441,602)--cycle;
\path[fill=UniBwMorange](2166,785)--(2162,787)..controls(2155,789)and(2151,779)..(2158,777)--(2162,775)--(2183,767)..controls(2194,764)and(2200,762)..(2211,762)..controls(2243,760)and(2249,768)..(2276,780)..controls(2307,793)and(2324,804)..(2362,804)..controls(2400,803)and(2446,780)..(2480,763)..controls(2486,759)and(2491,768)..(2485,772)..controls(2451,798)and(2396,823)..(2352,823)..controls(2290,823)and(2279,792)..(2225,779)..controls(2209,774)and(2182,779)..(2166,785)--cycle;
\path[fill=UniBwMorange](2164,406)..controls(2160,446)and(2164,484)..(2181,521)..controls(2196,553)and(2203,565)..(2204,603)..controls(2205,651)and(2201,678)..(2197,748)--(2197,751)..controls(2197,758)and(2177,761)..(2173,762)..controls(2145,771)and(2118,787)..(2096,807)..controls(2090,812)and(2083,806)..(2088,800)..controls(2106,777)and(2122,765)..(2146,753)..controls(2150,751)and(2165,744)..(2178,740)..controls(2181,700)and(2188,591)..(2181,567)..controls(2176,550)and(2166,535)..(2160,519)..controls(2150,491)and(2144,450)..(2145,420)..controls(2147,391)and(2155,362)..(2169,337)..controls(2173,330)and(2182,334)..(2179,341)..controls(2170,366)and(2167,380)..(2164,406)--cycle;
\path[fill=UniBwMorange](2271,714)..controls(2264,721)and(2252,729)..(2238,729)..controls(2230,730)and(2229,721)..(2236,719)..controls(2247,716)and(2256,709)..(2261,703)..controls(2264,701)and(2269,692)..(2274,679)..controls(2277,672)and(2285,674)..(2285,681)..controls(2283,697)and(2276,709)..(2271,714)--cycle;
\path[fill=UniBwMorange](2300,635)..controls(2299,630)and(2301,620)..(2304,611)..controls(2306,604)and(2316,607)..(2314,614)..controls(2311,625)and(2312,630)..(2316,640)..controls(2317,644)and(2319,647)..(2322,650)..controls(2327,656)and(2319,663)..(2314,658)..controls(2306,650)and(2301,641)..(2300,635)--cycle;
\path[fill=UniBwMorange](2484,495)..controls(2467,494)and(2458,501)..(2449,507)..controls(2443,511)and(2437,506)..(2441,500)..controls(2454,480)and(2475,476)..(2497,478)..controls(2506,478)and(2516,510)..(2501,501)..controls(2494,497)and(2489,495)..(2484,495)--cycle;
\path[fill=UniBwMorange](2230,417)..controls(2216,468)and(2229,507)..(2273,537)..controls(2275,538)and(2276,542)..(2275,544)..controls(2269,554)and(2268,566)..(2271,578)..controls(2273,584)and(2265,588)..(2261,582)..controls(2254,571)and(2251,558)..(2253,545)..controls(2219,523)and(2203,487)..(2206,446)..controls(2208,414)and(2226,380)..(2248,356)..controls(2253,351)and(2261,357)..(2256,363)..controls(2242,382)and(2236,394)..(2230,417)--cycle;
\path[fill=UniBwMorange](2439,669)--(2443,669)..controls(2446,669)and(2447,669)..(2447,667)..controls(2440,648)and(2463,658)..(2471,660)..controls(2471,641)and(2470,619)..(2470,604)..controls(2470,594)and(2482,583)..(2486,573)..controls(2487,571)and(2489,566)..(2491,561)..controls(2476,567)and(2459,559)..(2448,547)..controls(2444,542)and(2449,535)..(2455,539)..controls(2468,548)and(2480,552)..(2493,541)..controls(2498,539)and(2501,540)..(2504,542)--(2507,544)..controls(2513,536)and(2512,526)..(2509,517)..controls(2506,507)and(2501,501)..(2491,496)--(2464,451)..controls(2456,435)and(2463,413)..(2446,396)..controls(2442,392)and(2432,389)..(2431,386)..controls(2425,373)and(2409,348)..(2396,340)..controls(2380,330)and(2346,328)..(2327,329)..controls(2320,330)and(2318,320)..(2326,319)..controls(2337,317)and(2348,316)..(2359,316)..controls(2358,308)and(2356,274)..(2362,268)--(2372,258)--(2366,254)--(2344,249)--(2308,246)..controls(2301,246)and(2301,236)..(2308,236)..controls(2308,236)and(2330,232)..(2343,233)..controls(2354,234)and(2361,234)..(2371,238)..controls(2382,244)and(2398,253)..(2379,271)--(2375,276)..controls(2372,289)and(2373,303)..(2377,316)..controls(2408,322)and(2430,346)..(2443,373)..controls(2469,385)and(2480,417)..(2481,443)..controls(2487,457)and(2494,471)..(2503,483)..controls(2515,488)and(2523,503)..(2525,509)..controls(2529,522)and(2532,554)..(2516,561)..controls(2515,562)and(2514,562)..(2512,563)..controls(2509,565)and(2507,567)..(2505,568)..controls(2500,578)and(2495,587)..(2489,597)..controls(2487,599)and(2484,605)..(2484,608)..controls(2484,632)and(2484,650)..(2485,668)..controls(2485,678)and(2470,672)..(2460,670)..controls(2459,673)and(2458,675)..(2456,677)..controls(2456,684)and(2453,691)..(2447,695)..controls(2447,698)and(2450,705)..(2450,709)..controls(2450,715)and(2447,719)..(2444,723)..controls(2467,735)and(2481,730)..(2505,734)..controls(2546,740)and(2574,776)..(2593,809)--(2597,831)..controls(2599,839)and(2590,841)..(2587,834)..controls(2574,802)and(2550,767)..(2516,753)..controls(2494,744)and(2490,747)..(2469,746)..controls(2452,745)and(2446,736)..(2431,735)..controls(2423,734)and(2415,732)..(2407,730)..controls(2406,732)and(2405,733)..(2404,736)..controls(2401,742)and(2402,759)..(2402,766)..controls(2402,773)and(2392,774)..(2391,767)..controls(2389,750)and(2386,744)..(2389,727)..controls(2372,721)and(2361,713)..(2349,701)..controls(2345,698)and(2342,694)..(2337,689)..controls(2332,683)and(2340,677)..(2345,682)..controls(2349,686)and(2352,690)..(2356,693)..controls(2359,696)and(2363,699)..(2367,701)..controls(2379,710)and(2388,713)..(2401,717)--(2421,720)..controls(2437,722)and(2438,702)..(2434,694)..controls(2432,691)and(2435,687)..(2437,684)..controls(2428,682)and(2419,679)..(2412,675)..controls(2405,671)and(2409,663)..(2416,665)..controls(2424,668)and(2431,669)..(2439,669)--cycle;
\path[fill=UniBwMorange](2421,454)..controls(2406,458)and(2398,461)..(2384,468)..controls(2377,472)and(2372,464)..(2378,459)..controls(2399,444)and(2423,437)..(2449,438)..controls(2457,438)and(2457,448)..(2450,449)..controls(2438,450)and(2432,451)..(2421,454)--cycle;
\path[fill=UniBwMorange](2298,549)..controls(2308,537)and(2315,523)..(2318,508)..controls(2320,502)and(2326,502)..(2328,508)..controls(2332,517)and(2340,522)..(2350,523)..controls(2358,523)and(2358,533)..(2351,534)..controls(2343,535)and(2335,534)..(2327,532)..controls(2319,550)and(2306,566)..(2288,575)..controls(2281,578)and(2276,570)..(2282,566)..controls(2289,560)and(2293,556)..(2298,549)--cycle;
\end{tikzpicture}
}}

\endinput
