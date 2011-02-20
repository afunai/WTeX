# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WikiTeX < Test::Unit::TestCase

  def setup
    @wt = WikiTeX.new
  end

  def teardown
  end

  def test_instance
    wt = nil
    assert_nothing_raised(
      'WikiTex.new should return a proper instance'
    ) {
      wt = WikiTeX.new
    }
    assert_instance_of(
      WikiTeX,
      wt,
      'WikiTex.new should return a proper instance'
    )
  end

  def test_tex_heading
    [
      '!foo',
      '! foo',
      "! foo\n",
    ].each {|w|
      assert_equal(
        "\\subsection{foo}\n",
        @wt.tex(w.dup),
        "WikiTeX#tex should convert #{w.inspect} into \\subsection{foo}"
      )
    }

    assert_equal(
      "\\section{bar}\n",
      @wt.tex('!! bar'),
      'WikiTeX#tex should convert "!! bar" into \\section{bar}'
    )
    assert_equal(
      "\\chapter{baz}\n",
      @wt.tex('!!! baz'),
      'WikiTeX#tex should convert "!!! baz" into \\chapter{baz}'
    )

    assert_equal(
      "\\chapter{baz}\n",
      @wt.tex('!!!!! baz'),
      'WikiTeX#tex should convert more than 4 "!"s into \\chapter{}'
    )
  end

  def test_tex_heading_combination
    w = <<'_eos'
!!! foo

!! bar

_eos
    assert_equal(
      <<'_eos',
\chapter{foo}

\section{bar}

_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with multiple headings'
    )

    w = <<'_eos'
!!! foo
!! bar

_eos
    assert_equal(
      <<'_eos',
\chapter{foo}
\section{bar}

_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with sequence of headings'
    )
  end

  def test_tex_p
    w = <<'_eos'
foo
bar
_eos
    assert_equal(
      <<'_eos',
foo\\
bar
_eos
      @wt.tex(w),
      'WikiTeX#tex should append new line commands explicitly'
    )
  end

  def test_tex_p_multiple
    w = <<'_eos'
foo
bar

baz
qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar

baz\\
qux

boo
_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with multiple paragraphs'
    )

    w = <<'_eos'
foo
bar
baz

qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar\\
baz

qux

boo
_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with multiple paragraphs'
    )
  end

  def test_tex_p_combination
    w = <<'_eos'
!!! foo

baz
qux

boo
_eos
    assert_equal(
      <<'_eos',
\chapter{foo}

baz\\
qux

boo
_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with combination of commands and paragraphs'
    )

    w = <<'_eos'
foo
bar

!! qux

boo
_eos
    assert_equal(
      <<'_eos',
foo\\
bar

\section{qux}

boo
_eos
      @wt.tex(w),
      'WikiTeX#tex should deal with combination of commands and paragraphs'
    )
  end

  def test_tex_newpage
    w = <<'_eos'
foo
---
bar
_eos
    assert_equal(
      <<'_eos',
foo
\newpage
bar
_eos
      @wt.tex(w),
      'WikiTeX#tex should convert "---" into \\newpage'
    )

    w = <<'_eos'
foo
---------
_eos
    assert_equal(
      <<'_eos',
foo
\newpage
_eos
      @wt.tex(w),
      'WikiTeX#tex should convert more than 3 "-"s into \\newpage as well'
    )
  end

  def test_tex_box
    w = <<'_eos'
foo:
] ***big***
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox}{foo}
 {\LARGE\bf big}
\end{WTbox}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with ')' into boxed block"
    )

    w = <<'_eos'
] ***big***
_eos
    assert_equal(
      <<'_eos',
\begin{WTbox-without-title}
 {\LARGE\bf big}
\end{WTbox-without-title}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with ')' into boxed block"
    )
  end

  def test_tex_code
    w = <<'_eos'
foo.rb:
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode}{foo.rb}
a = 123
 b = 456 * 789
\end{WTcode}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
foo.rb:
bbb|a = 123
_eos
    assert_equal(
      <<'_eos',
foo.rb:\\
bbb\textbar{}a = 123
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
foo_bar.rb:
|a = 123
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode}{foo\_{}bar.rb}
a = 123
\end{WTcode}
_eos
      @wt.tex(w),
      'WikiTeX#tex should escape title of code blocks'
    )
  end

  def test_tex_code_without_title
    w = <<'_eos'
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode-without-title}
a = 123
 b = 456 * 789
\end{WTcode-without-title}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '|' into code block"
    )

    w = <<'_eos'
|foo.rb:
|a = 123
| b = 456 * 789
_eos
    assert_equal(
      <<'_eos',
\begin{WTcode-without-title}
foo.rb:
a = 123
 b = 456 * 789
\end{WTcode-without-title}
_eos
      @wt.tex(w),
      "WikiTeX#tex should not treat lines which begin with '|' as a title"
    )
  end

  def test_tex_quote
    w = <<'_eos'
>a = 123
> b = 456 & 789
_eos
    assert_equal(
      <<'_eos',
\begin{quote}
a = 123\\
 b = 456 \&{} 789
\end{quote}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '>' into quote"
    )
  end

  def test_tex_itemize
    w = <<'_eos'
* foo
* bar
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo
\item bar
\end{itemize}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '*' into list"
    )

    w = <<'_eos'
* **baz**
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item {\large\bf baz}
\end{itemize}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '*' into list"
    )
  end

  def test_tex_itemize_ambiguous
    w = <<'_eos'
*foo
_eos
    assert_equal(
      <<'_eos',
*foo
_eos
      @wt.tex(w),
      "WikiTeX#tex should not convert lines with '*' and immidiate strings without spaces"
    )
  end

  def test_tex_enumerate
    w = <<'_eos'
+ foo
+ bar
_eos
    assert_equal(
      <<'_eos',
\begin{enumerate}
\item foo
\item bar
\end{enumerate}
_eos
      @wt.tex(w),
      "WikiTeX#tex should convert lines which begin with '+' into list"
    )
  end

  def test_tex_nested_list
    w = <<'_eos'
* foo
** bar
** baz
* qux
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo\begin{itemize}
\item bar
\item baz
\end{itemize}

\item qux
\end{itemize}
_eos
      @wt.tex(w),
      'WikiTeX#tex should handle nested lists'
    )
  end

  def test_tex_mixed_list
    w = <<'_eos'
* foo
*+ bar
*+ baz
* qux
_eos
    assert_equal(
      <<'_eos',
\begin{itemize}
\item foo\begin{enumerate}
\item bar
\item baz
\end{enumerate}

\item qux
\end{itemize}
_eos
      @wt.tex(w),
      'WikiTeX#tex should handle mixed lists'
    )
  end

end
