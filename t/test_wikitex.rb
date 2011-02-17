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
        "\\chapter{foo}\n",
        @wt.tex(w.dup),
        "WikiTeX#tex should convert #{w.inspect} into \\chapter{foo}"
      )
    }

    assert_equal(
      "\\section{bar}\n",
      @wt.tex('!! bar'),
      'WikiTeX#tex should convert "!! bar" into \\section{bar}'
    )
    assert_equal(
      "\\subsection{baz}\n",
      @wt.tex('!!! baz'),
      'WikiTeX#tex should convert "!!! baz" into \\subsection{baz}'
    )

    assert_equal(
      "\\subsection{baz}\n",
      @wt.tex('!!!!! baz'),
      'WikiTeX#tex should convert more than 4 "!"s into \\subsection{}'
    )
  end

  def test_tex_heading_combination
    w = <<'_eos'
! foo

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
! foo
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
! foo

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

end
