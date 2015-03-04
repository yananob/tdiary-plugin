# fm.rb $Revision: 1.0 $
#
# fm: facemark image tag generator
#   Parameters:
#     mark: facemark.
#
# @options['fm.dic']
#   array of dictionary table array. an item of array is:
#
#       [mark, filename]
#
#   mark:       facemark.
#   filename:   Image filename.
#
# Document: http://yananob.blogspot.jp/2005/04/tdiary.html
# 
# Script by http://nicher.jp/ based on kw.rb & template.rb
# You can distribute this under GPL.
#

#
# funcs
#

# Parse conf text and return array
def fm_parse( str )
	fm_list = []
	str.each do |pair|
		m, f = pair.sub( /[\n]+/, '' ).split( /[ \t]+/, 2 )
		fm_list << [m, f]
	end
	fm_list
end

# Generate hash of facemark dictionary from conf
def fm_generate_dic
	fm_dic = Hash.new
	
	fm_list = []
	case @conf['fm.dic'].class.to_s
	when "String"
		fm_list = fm_parse( @conf['fm.dic'] )
	when "Array"
		fm_list = @conf['fm.dic']
	end
	fm_list.each do |pair|
		fm_dic[pair[0]] = pair[1]
	end
	fm_dic
end

# Return image tag str
def fm_image_tag( baseurl, mark, filename, style)
	fm_tag = "<img src=\"#{baseurl}#{filename}\" alt=\"#{mark}\" style=\"#{style}\">"
	fm_tag
end

# Return front&end str for plugin (made for common use)
def fm_plugin (plugin_name, param)
	
	ptag = Array.new
	
	case @conf.style.sub( /^blog/i, '' )
	when /^wiki$/i
		ptag[0] = "{{"
		ptag[1] = "}}"
	when /^rd$/i
		ptag[0] = "((%"
		ptag[1] = "%))"
	else
		ptag[0] = "<%="
		ptag[1] = "%>"
	end
	
	ptag
end

#
# main
#
def fm( mark )
	@fm_dic = fm_generate_dic unless @fm_dic
	fm_tag = fm_image_tag( @conf['fm.baseurl'], mark, @fm_dic[mark], @conf['fm.style'] )
	
	%Q[#{fm_tag}]
end

#
# edit
#
add_edit_proc do |date|
	$KCODE = 'EUC'
	fm_dic = fm_generate_dic unless fm_dic
	
	fm_list = Array.new
	fm_dic.each do |mark, filename|
		fm_tag = fm_image_tag( @conf['fm.baseurl'], mark, filename, @conf['fm.style'] )
		fm_list.push("<a href=\"javascript:inj_fm(&quot;#{mark}&quot;)\">#{fm_tag}</a>")
	end
	fm_line = fm_list.join('|')
	
	ptag = fm_plugin('fm', 'val')
	
	<<"HTML"
<script type="text/javascript">
<!--
function inj_fm(val){
	target = window.document.forms[0].body
	target.focus();
	target.value += '#{ptag[0]}fm "' + val + '"#{ptag[1]} ';
}
//-->
</script>
<div class="field title">顔文字: #{fm_line}</div>
HTML
end

#
# config
#
unless @resource_loaded then
	def fm_label
		"顔文字プラグイン"
	end
end

add_conf_proc( 'fm', fm_label ) do
	if @mode == 'saveconf' then
#		必ず"/"で終わるように保存
		baseurl = @cgi.params['fm.baseurl'][0]
		baseurl += "/" if (not baseurl.match(/\/$/))
		@conf['fm.baseurl'] = baseurl
		
		fm_list = fm_parse( @cgi.params['fm.dic'][0] )
		if fm_list.empty? then
			@conf.delete( 'fm.dic' )
		else
			@conf['fm.dic'] = fm_list.collect{|a|a.join( ' ' )}.join( "\n" )
		end
		
		@conf['fm.style'] = @cgi.params['fm.style'][0]
	end
	dic = fm_generate_dic
	if dic[nil] then
		dic['nil'] = dic[nil]
		dic.delete( nil )
	end
	<<-HTML
	<p>特定のサイトへのリンクを、簡単な記述で生成するためのプラグイン(fm)です。</p>
	<br>
	<h3>画像のベースアドレスの指定</h3>
	<p>顔文字画像が置かれているフォルダへのURLを指定します。<br>
	（最後は"/"で終わるように）</p>
	<p><input type="text" name="fm.baseurl" size="70" value="#{@conf['fm.baseurl']}">
	<br>
	<h3>顔文字リストの指定</h3>
	<p>「顔文字 画像ファイル名」と、空白で区切って指定します。<br>
	例えば、</p>
	<pre>:) smile.png</pre>
	<p>と指定して、</p>
	<pre>&lt;%=fm(':)')%&gt;</pre>
	<p>のように日記に書けば、笑顔の顔文字画像が表示されます。<br>
	(記述方法はスタイルによって変わります)。</p>
	<p><textarea name="fm.dic" cols="70" rows="10">#{dic.collect{|a|a.flatten.join( " " )}.join( "\n" )}</textarea>
	<br>
	<h3>拡張スタイルの指定</h3>
	<p>画像に対して指定するスタイルシート指定がある場合は、ここに指定します。<br>
	例えば、</p>
	<pre>border-width: 0px;</pre>
	<p>のように指定すると、画像のフチが0pxになります。</p>
	<p><input type="text" name="fm.style" size="70" value="#{@conf['fm.style']}"></p>
	HTML
end

