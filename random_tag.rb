# random_tag.rb $Revision: 1.0 $
#
# random_tag: display random tag from registered list
#   Parameters:
#     none.
#
# @options['random_tag.dic']
#   array of dictionary table array. an item of array is:
#
#       [tagname, tag]
#
#   tagname:       Tag name.
#   tag:           Tag.
#
# Script by http://nicher.jp/ based on fm.rb
# You can distribute this under GPL.
#

#
# funcs
#

# Parse conf text and return array
def random_tag_parse( str )
	random_tag_list = []
	
	line = str.split( /\|\|\|random_tag_line\|\|\|/ )
	line.each do |pair|
		m, f = pair.split( /\|\|\|random_tag_item\|\|\|/, 2 )
		random_tag_list << [m, f]
	end
	random_tag_list
end

# Generate hash of facemark dictionary from conf
def random_tag_generate_dic
	random_tag_dic = Hash.new
	
	random_tag_list = []
	case @conf['random_tag.dic'].class.to_s
	when "String"		# generate from conf
		random_tag_list = random_tag_parse( @conf['random_tag.dic'] )
	when "Array"		# generate from input
		random_tag_list = @conf['random_tag.dic']
	end
	random_tag_list.each do |pair|
		random_tag_dic[pair[0]] = pair[1]
	end
	random_tag_dic
end

def random_tag_texttag( no, tagname, tag )
	result = ""
	
	result += "<hr>\n"
	result += "<p><a name=\"random_tag_#{no}\">#{no})</a> タグ名称 : <input type=\"text\" name=\"" + random_tag_getnamefield(no) + "\" size=\"30\" value=\"#{tagname}\"> <a href=\"javascript:random_tag_clearItem('#{no}')\">空にする</a></p>\n"
	result += "<p><textarea name=\"" + random_tag_gettagfield(no) + "\" cols=\"70\" rows=\"10\">#{tag}</textarea></p>\n"
	
	result
end

def random_tag_getnamefield( no = "" ) 
	result = "random_tag_name#{no}"
	result
end

def random_tag_gettagfield( no = "" )
	result = "random_tag_tag#{no}"
	result
end

#
# main
#
def random_tag
	@random_tag_dic = random_tag_generate_dic unless @random_tag_dic
	
	values = @random_tag_dic.values
	index = rand(values.size)
	random_tag_tag = values[index]
	
	%Q[#{random_tag_tag}]
end

#
# config
#
unless @resource_loaded then
	def random_tag_label
		"タグローテーション"
	end
end

add_conf_proc( 'random_tag', random_tag_label ) do

#	for debug
#	@conf.delete( 'random_tag.dic' )
	
	if @mode == 'saveconf' then
		random_tag_list = []
		index = 1
		while @cgi.has_key?(random_tag_getnamefield(index))
			tagname = @cgi.params[random_tag_getnamefield(index)][0]
			tag = @cgi.params[random_tag_gettagfield(index)][0]
			
			if (not tagname.empty? or not tag.empty?)
				random_tag_list << [tagname, tag]
			end
			index += 1
		end
		@conf['random_tag.dic'] = random_tag_list.collect{|a|a.join( '|||random_tag_item|||' )}.join( '|||random_tag_line|||' )
	end
	
	dic = random_tag_generate_dic
	if dic[nil] then
		dic['nil'] = dic[nil]
		dic.delete( nil )
	end
	
	list = ""
	result = ""
	
	index = 1
	dic.each do |key, value|
		list += "<li><a href=\"#random_tag_#{index}\">#{key}</a></li>\n"
		
		result += random_tag_texttag(index, key, value)
		index += 1
	end
	
	list += "<li><a href=\"#random_tag_#{index}\">(新しく追加)</a></li>\n"
	result += random_tag_texttag(index, "", "")
	
	<<-HTML
<script type="text/javascript">
<!--
function random_tag_clearItem(no){
	target = window.document.forms[0];
	eval("target.#{random_tag_getnamefield}" + no + ".value = '';");
	eval("target.#{random_tag_gettagfield}" + no + ".value = '';");
}
//-->
</script>
	<p>設定したタグを、ランダムにローテーション表示するプラグインです。 -> <a href="http://nicher.jp/modules/bwiki/tDiary/random_tag.rb.html">配布元はこちらです。</a></p>
	設定済リスト: 
	<ul>
		#{list}
	</ul>
	<h3>タグリストの指定</h3>
	<p>表示するタグリストを指定します。<br>
	「タグ名称」は画面には表示されませんが、便宜上名前を付けたいときに、指定してください。</p>
	<p>登録済みの内容を削除したい場合は、空にして[OK]ボタンを押してください。</p>
	#{result}
	HTML
end
