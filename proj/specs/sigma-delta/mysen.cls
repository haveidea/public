\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{mysen}[2008/07/01 mysen, tech report class, version 1.0.0]

%%==========================================
%%   class and packages

%%%%%%%%%%%%%%%%%%%%
%% Options
%%%%%%%%%%%%%%%%%%%%

%% disable oneside option
\DeclareOption{oneside}{\OptionNotUsed}

%% bold
\newif\ifmysen@Option@titlebold \mysen@Option@titleboldtrue
\DeclareOption{nbold}{\mysen@Option@titleboldfalse}

%% driver
\newif\ifmysen@Option@dvipdfm \mysen@Option@dvipdfmtrue
\DeclareOption{dvips}{\mysen@Option@dvipdfmfalse}
\DeclareOption{dvipdfm}{\mysen@Option@dvipdfmtrue}

%% print version or electronic version
\newif\ifmysen@Option@PrintVersion \mysen@Option@PrintVersiontrue
\DeclareOption{pversion}{\mysen@Option@PrintVersiontrue}
\DeclareOption{eversion}{\mysen@Option@PrintVersionfalse}

%% info
\newif\ifmysen@Option@info \mysen@Option@infotrue
\DeclareOption{noinfo}{\mysen@Option@infofalse}

%% ref
\newif\ifmysen@Option@ref@sort \mysen@Option@ref@sortfalse
\newif\ifmysen@Option@ref@compress \mysen@Option@ref@compressfalse
\DeclareOption{refsort}{\mysen@Option@ref@sorttrue}
\DeclareOption{refcompress}
  {\mysen@Option@ref@sorttrue\mysen@Option@ref@compresstrue}

%% others
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessOptions\relax

%% newcommands
\newcommand{\reffig}[1]{图\ref{#1}}

%% renewcommands


%%%%%%%%%%%%%%%%%%%%
%% load class and packages
%%%%%%%%%%%%%%%%%%%%

%% book
\LoadClass[a4paper,cs4size,twoside,openright,fancyhdr,fntef,punct]{ctexbook}

%% ifthen
\RequirePackage{ifthen}

%% ifpdf
\RequirePackage{ifpdf}

%% natbib
\ifmysen@Option@ref@sort
  \ifmysen@Option@ref@compress
    \RequirePackage[numbers,sort&compress]{natbib}
  \else
    \RequirePackage[numbers,sort]{natbib}
  \fi
\fi

%% hyperref
\ifpdf
  \RequirePackage[pdftex]{hyperref}
\else
  \ifmysen@Option@dvipdfm
    \RequirePackage[dvipdfm]{hyperref}
  \else
    \RequirePackage[dvips]{hyperref}
  \fi
\fi

%% color
\ifmysen@Option@PrintVersion\relax\else
  \RequirePackage{color}
\fi

%% config file
\AtEndOfPackage{\makeatletter\input{mysen.def}\makeatother}
\AtEndOfPackage{\makeatletter\input{mysen.cfg}\makeatother}

%%%%%%%%%%%%%%%%%%%%
%% setup packages
%%%%%%%%%%%%%%%%%%%%

%% hyperref
  % GBK -> Unicode
\AtBeginDvi{\special{pdf:tounicode GBK-EUC-UCS2}}
  % setup
\ifmysen@Option@PrintVersion
  \hypersetup{
    a4paper,
    CJKbookmarks,
    bookmarksnumbered,
    plainpages    = false,
    pdfstartview  = FitH
  }
\else
  \definecolor{mysen@hypercolor@darkgreen}{rgb}{0.1,0.5,0.1}
  \hypersetup{
    a4paper,
    CJKbookmarks,
    bookmarksnumbered,
    colorlinks,
    linkcolor     = blue,
    anchorcolor   = blue,
    citecolor     = blue,
    urlcolor      = mysen@hypercolor@darkgreen,
    plainpages    = false,
    pdfstartview  = FitH
  }
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   utilities

\DeclareRobustCommand{\mysen@toc@add}[1]
  {\phantomsection\addcontentsline{toc}{chapter}{#1}}

%% underline
\def\mysen@@underline[#1]#2{\CTEXunderline{\hbox to #1{\hfill{#2}\hfill}}}
\DeclareRobustCommand{\mysen@underline}
  {\@ifnextchar[\mysen@@underline\CTEXunderline}

%% bold (for title)
\ifmysen@Option@titlebold
  \DeclareRobustCommand*{\mysen@bold@title}{\bfseries}
\else
  \DeclareRobustCommand*{\mysen@bold@title}{\relax}
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    font

%% family
\DeclareRobustCommand*{\mysen@font@st}{\songti}
\DeclareRobustCommand*{\mysen@font@ht}{\heiti}
\DeclareRobustCommand*{\mysen@font@fs}{\fangsong}
\DeclareRobustCommand*{\mysen@font@ks}{\kaishu}
\DeclareRobustCommand*{\mysen@font@ls}{\lishu}
\DeclareRobustCommand*{\mysen@font@yy}{\youyuan}

%% size
\DeclareRobustCommand*{\mysen@font@zihao}[1]{\zihao{#1}}
\renewcommand*{\baselinestretch}{1.3}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    document setting

%% page
\hoffset 0 mm
\voffset 0 mm
\ifmysen@Option@PrintVersion
  \oddsidemargin 0.5 cm
  \evensidemargin -0.5 cm
\else
  \oddsidemargin 0 cm
  \evensidemargin 0 cm
\fi
\topmargin 0 pt
\headheight 15 pt
%\headsep
\textwidth 16 cm
\textheight 23.7 cm
%\footskip

%% par skip
\parskip 0.5ex plus 0.25ex minus 0.25ex

%% section level
\setcounter{secnumdepth}{4}

%% chapter
\CTEXsetup[name={\mysen@chapter@prenumber,\mysen@chapter@afternumber},
           %number={\chinese{chapter}},
           number={\arabic{chapter}},
           format={\centering\mysen@bold@title\mysen@font@ht\mysen@font@zihao{4}},
           nameformat={},
           numberformat={},
           aftername={\quad},
           titleformat={},
           beforeskip={15pt},
           afterskip={12pt},
           indent={0pt}]{chapter}

%\makeatletter
%\renewcommand\thefigure{\@arabic\c@section--\@arabic\c@figure}%
%\long\def\@makecaption#1#2{%
%\vskip\abovecaptionskip
%\sbox\@tempboxa{#1\hskip 1em#2}%
%\ifdim \wd\@tempboxa >\hsize
%  #1\hskip 1em#2\par
%\else
%  \global \@minipagefalse
%  \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
%\fi
%\vskip\belowcaptionskip}
%\makeatother

%% chapter without number
\DeclareRobustCommand{\mysen@nchapter}[1]{\chapter*{#1}}

%% section
\CTEXsetup[name={,},
           number={\thesection},
           format={\raggedright\mysen@bold@title\mysen@font@ht\mysen@font@zihao{-4}},
           nameformat={},
           numberformat={},
           aftername={\quad},
           titleformat={},
           beforeskip={-3ex plus -1ex minus -.2ex},
           afterskip={1.0ex plus .2ex},
           indent={0pt}]{section}

%% subsection
\CTEXsetup[name={,},
           number={\thesubsection},
           format={\raggedright\mysen@bold@title\mysen@font@ht\mysen@font@zihao{-4}},
           nameformat={},
           numberformat={},
           aftername={\quad},
           titleformat={},
           beforeskip={-2.5ex plus -1ex minus -.2ex},
           afterskip={1.0ex plus .2ex},
           indent={2\ccwd}]{subsection}

%% subsubsection
\CTEXsetup[name={,},
           number={\thesubsubsection},
           format={\raggedright\mysen@bold@title\mysen@font@ht\mysen@font@zihao{-4}},
           nameformat={},
           numberformat={},
           aftername={\quad},
           titleformat={},
           beforeskip={-2ex plus -1ex minus -.2ex},
           afterskip={1.0ex plus .2ex},
           indent={2\ccwd}]{subsubsection}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    figure and table

%% figure name
\CTEXoptions[figurename={\mysen@label@figure@cap}]

%% table name
\CTEXoptions[tablename={\mysen@label@table@cap}]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    head and foot

%% remove header from empty page
\renewcommand{\cleardoublepage}
  {\clearpage%
   \ifodd%
     \c@page%
   \else%
     \thispagestyle{empty}%
     \hbox{}\newpage%
     \if@twocolumn%
       \hbox{}\newpage%
     \fi%
   \fi}

%% label of even page header
\def\mysen@hdr@thesis
  {{\mysen@value@thesis@type}{\mysen@value@thesis@title}}
\def\mysen@hdr@thesistitle
  {{\mysen@value@thesis@title}}

%% set header
\pagestyle{fancy}
\fancyhf{}
\fancyhead[CE]{{\mysen@font@ht\mysen@hdr@thesistitle}}
\fancyhead[CO]{{\mysen@font@ht\leftmark}}
\fancyfoot[C]{{\mysen@font@ht\thepage}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    cover

\DeclareRobustCommand{\mysen@make@title}
  {{\cleardoublepage\CTEXnoindent\thispagestyle{empty}%
   \begin{center}%
    \vskip 5pt%
       \hfill%
     \normalfont\mysen@font@st\mysen@font@zihao{-4}%
     \mysen@label@cover@No~%
     \mysen@underline[70pt]{\mysen@value@thesis@No}\hspace*{1em}%

    \vskip 70pt%
       %% \hfill%
% \includegraphics[width=0.8\textwidth]{mysen_logo.eps}\\%

%\includegraphics[width=0.5\textwidth]{ece_logo.eps}\\%
    \vskip \stretch{1}%
     \normalfont\mysen@bold@title\mysen@font@ht\mysen@font@zihao{-1}%

     \vskip 5pt%

     \mysen@value@thesis@type%
    \vskip \stretch{2}%
     \normalfont\mysen@bold@title\mysen@font@ht\mysen@font@zihao{-1}%
     \mysen@underline{\raisebox{0.7ex}{\hspace*{1em}\mysen@value@thesis@title\hspace*{1em}}}%

    \vskip \stretch{2}%
     \normalfont\mysen@font@st\bfseries\mysen@font@zihao{-4}%
     \setlength{\tabcolsep}{0pt}\renewcommand{\arraystretch}{1.5}%
     \begin{tabular}{lclllccl}%
	  \mysen@label@cover@version & \multicolumn{7}{l}{\mysen@value@version@name}\\%
   %  \mysen@label@cover@author & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@author@name}}\\%
   %  \mysen@label@cover@advisor & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@advisor@name~~~\mysen@value@advisor@title}}\\%
   %  & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@advisor@institute}}\\%
   %  \mysen@label@cover@degree & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@degree}}\\%
   %  \mysen@label@cover@major & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@author@major}}\\%
   % \mysen@label@cover@institute & \multicolumn{7}{l}{\mysen@underline[310pt]{\mysen@value@author@institute}}\\%
    \end{tabular}%
	%
     \vskip 50pt%
     \mysen@value@thesis@date
    \vskip \stretch{1}%
 % \includegraphics[width=0.5\textwidth]{ece_logo.eps}\\
 \end{center}%

   \clearpage\thispagestyle{empty}%
   \ifmysen@Option@info%
     \normalfont\mysen@font@zihao{5}\vspace*{\stretch{10}}%
     Typeset by \LaTeX{} with Package \texttt{mysen}%
     \vspace*{\stretch{1}}\normalfont\mysen@font@zihao{-4}%
   \fi%
   \CTEXindent\cleardoublepage}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    content

%% content
\CTEXoptions[contentsname={\mysen@label@content}]
\DeclareRobustCommand{\mysen@tableofcontents}
  {\cleardoublepage\mysen@toc@add{\mysen@toc@content}%
   \tableofcontents}

%% list of figures
\CTEXoptions[listfigurename={\mysen@label@listoffigures}]
\DeclareRobustCommand{\mysen@listoffigures}
  {\cleardoublepage\mysen@toc@add{\mysen@toc@listoffigures}%
   \listoffigures}

%% list of tables
\CTEXoptions[listtablename={\mysen@label@listoftables}]
\DeclareRobustCommand{\mysen@listoftables}
  {\cleardoublepage\mysen@toc@add{\mysen@toc@listoftables}%
   \listoftables}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    referrence

\CTEXoptions[bibname={\mysen@label@ref@title}]
\bibliographystyle{plain}

\renewenvironment{thebibliography}[1]
  {\cleardoublepage\mysen@toc@add{\mysen@toc@ref@title}%
   \mysen@nchapter{\bibname}%
   \@mkboth{\MakeUppercase\bibname}{\MakeUppercase\bibname}%
   \list{\@biblabel{\@arabic\c@enumiv}}%
    {\settowidth\labelwidth{\@biblabel{#1}}%
     \leftmargin\labelwidth\advance\leftmargin\labelsep%
     \@openbib@code\usecounter{enumiv}\let\p@enumiv\@empty%
     \renewcommand\theenumiv{\@arabic\c@enumiv}}%
   \sloppy\clubpenalty4000\@clubpenalty\clubpenalty%
   \widowpenalty4000\sfcode`\.\@m}
  {\def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
   \endlist}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    thesis structure

%%%% front matter
\DeclareRobustCommand{\mysenfrontmatter}
  {\mysen@make@title
   \frontmatter\cleardoublepage\pagenumbering{Roman}}
%%  {\mysen@make@title\mysen@make@titleenglish\mysen@make@statementandcopyright%
%%   \frontmatter\cleardoublepage\pagenumbering{Roman}}

%% main matter
\DeclareRobustCommand{\mysenmainmatter}
  {\mysen@tableofcontents\mysen@listoffigures%
   \mysen@listoftables\mainmatter}

%% back matter
\DeclareRobustCommand{\mysenbackmatter}[1]
  {\backmatter{}#1{}\cleardoublepage\pagenumbering{roman}}
%
%\renewcommand*\appendixname{\mysen@appendixname}
%%\let\mysen@save@appendix\appendix
%\renewcommand*\appendix{\mysen@save@appendix%
%  \gdef\mysen@presection{\mysen@appendixname}%
%  \gdef\mysen@thesection{\mysen@appendixnumber}%
%  \gdef\mysen@postsection{}}%
