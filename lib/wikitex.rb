#!/usr/bin/env ruby
# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require 'strscan'

class WikiTeX

  module Characters
    SPECIAL_MAP = {
      '#' => '\\#{}',
      '%' => '\\%{}',
      '&' => '\\&{}',
      '_' => '\\_{}',
      '<' => '\\textless{}',
      '>' => '\\textgreater{}',
      '^' => '\\textasciitilde{}',
      '|' => '\\textbar{}',
      '~' => '\\textasciicircum{}',
    }
    SPECIAL = SPECIAL_MAP.keys.join
    WITHOUT_RUBY = '\s|｜ぁ-んゝゞ\　、。，．？！´｀／∥…‥‘’“”（）〔〕［］｛｝〈〉《》「」『』【】♪'
  end

  def self.libdir
    ::File.dirname __FILE__
  end

  def tex(str)
    _tex str
  end

  private

  def _tex(str)
    tex  = ''
    body = ''
    line = ''
    type = :blank

    markups  = []
    rex_line = /(.*?)(\\|\$\$?|\{|\n|\z)/
    s = StringScanner.new str

    while !s.eos? && s.scan(rex_line)
      line += s[1]

      if s[2] =~ /\\|\$|\{/
        line += skip_tex_markup(s, s[2], markups)
        next unless s.match? /\z/
      end

      new_type = wiki_type(line, s)

      if (new_type != type) || single_line?(type)
        tex += __send__("element_#{type}", body.to_s)
        body = ''
      end

      body << line << "\n"
      type = new_type
      line = ''
    end

    tex += __send__("element_#{type}", body.to_s)
    tex.gsub(/\x00(\d+)/) { markups[$1.to_i] }
  end

  def skip_tex_markup(s, type, markups)
    if type == '\\'
      if s.scan /begin\{(.+?)\}/
        markups << scan_inner_contents(s, "\\begin{#{s[1]}}", "\\end{#{s[1]}}")
      elsif s.scan /verb/
        markups << (s.scan(/(.).*?\1/) ? "\\verb#{s[0]}" : '$\backslash$verb')
      elsif s.scan /.\w*/
        markups << ('\\' + s[0]) # command or escaped character
      end
    elsif type == '$$'
      markups << (s.scan(%r/.*?[^\\]\$\$|\$\$/m) ? "$$#{s[0]}" : '\\${}\\${}')
    elsif type == '$'
      markups << (s.scan(%r/.*?[^\\]\$|\$/m) ? "$#{s[0]}" : '\\${}')
    elsif type == '{'
      markups << scan_inner_contents(s, '{', '}')
    else
      return '???'
    end
    "\x00#{markups.size - 1}"
  end

  def scan_inner_contents(s, open_tag, close_tag)
    contents = ''
    rex = /(.*?)(\\?#{Regexp.quote(open_tag)}|\\?#{Regexp.quote(close_tag)}|\z)/m
    gen = 1
    until s.eos? || (gen < 1)
      contents << s.scan(rex)
      gen += 1 if s[2] == open_tag
      gen -= 1 if s[2] == close_tag
    end
    open_tag + contents
  end

  def wiki_type(line, s)
    case line
      when /^!/
        :heading
      when /^\]/
        :box
      when /^\|/
        :code
      when /^>/
        :quote
      when /^\*[\*\+]*\s/
        :itemize
      when /^\+[\*\+]*\s/
        :enumerate
      when /^---+$/
        :newpage
      when /^$/
        :blank
      when /:$/
        if s.match? /^\]/
          :box
        elsif s.match? /^\|/
          :code
        else
          :p
        end
      else
        :p
    end
  end

  def single_line?(type)
    [:heading, :newpage].include? type
  end

  def element_heading(body)
    body.chomp!
    body.gsub!(/(!+)\s*/, '')
    case $1
      when '!'
        "\\subsection{#{body}}\n"
      when '!!'
        "\\section{#{body}}\n"
      else
        "\\chapter{#{body}}\n"
    end
  end

  def element_box(body)
    _box(body, :box)
  end

  def element_code(body)
    _box(body, :code)
  end

  def _box(body, type = :box)
    if body.gsub!(/\A([^\]\|].*):\n/, '')
      title = escape_specials $1
    end
    body.gsub!(/^(\]|\|)/m, '')
    body = element_p(body) if type == :box
    if title
      <<_eos
\\begin{WT#{type}}{#{title}}
#{body}\\end{WT#{type}}
_eos
    else
      <<_eos
\\begin{WT#{type}-without-title}
#{body}\\end{WT#{type}-without-title}
_eos
    end
  end

  def element_quote(body)
    body.gsub!(/^>/m, '')
    <<_eos
\\begin{quote}
#{element_p body}\\end{quote}
_eos
  end

  def element_itemize(body)
    _list(body, 'itemize')
  end

  def element_enumerate(body)
    _list(body, 'enumerate')
  end

  def _list(body, item_enum)
    items = []
    lines = []
    type  = nil
    (body + "\n\n").each_line {|line|
      line.sub!(/^(\*|\+)/, '')

      unless line =~ /^(\*|\+)/ || lines.empty?
        item = inline lines.shift.to_s.chomp
        unless lines.empty?
          lines = lines.join
          item += (lines =~ /\A\*/) ? element_itemize(lines) : element_enumerate(lines)
        end
        items << "\\item#{item}\n" if item != ''
        lines = []
      end

      lines << line
    }

    <<_eos
\\begin{#{item_enum}}
#{items.join}\\end{#{item_enum}}
_eos
  end

  def element_newpage(body)
    "\\newpage\n"
  end

  def element_p(body)
    body.gsub!(/\n*\Z/, '')
    body.gsub!(/\n/, "\\\\\\\\\n")
    "#{inline body}\n"
  end

  def element_blank(body)
    body
  end

  def inline(body)
    body = convert_ruby      body
    body = convert_strong    body
    body = convert_underline body
    body = escape_specials   body
  end

  def convert_ruby(body)
    body.gsub!(/[｜\|]?([^#{Characters::WITHOUT_RUBY}]+)《(.+?)》/u, '\\\\ruby{\\1}{\\2}')
    body
  end

  def convert_strong(body)
    body.gsub!(/(\*{2,})(.*?)\1/) {
      case $1
        when '**'
          "{\\large\\bf #{$2}}"
        when '***'
          "{\\LARGE\\bf #{$2}}"
        else
          "{\\Huge\\bf #{$2}}"
      end
    }
    body
  end

  def convert_underline(body)
    body.gsub!(/__(.*?)__/, '\\WTunderline{\1}')
    body
  end

  def escape_specials(body)
    body.gsub!(/[#{Characters::SPECIAL}]/) { Characters::SPECIAL_MAP[$&] }
    body
  end

end
