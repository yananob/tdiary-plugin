# insert_html.rb $Revision: 1.0 $
#
# insert_html: insert html plugin
#   Parameters:
#     filename: filename to insert page.
#
# @options['insert_html.htmlpath']
#   base path where files to include are exists:
#
# Script by http://nicher.jp/
# http://yananob.blogspot.jp/2005/04/tdiary.html
# You can distribute this under GPL.
#

#
# funcs
#

#
# main
#
def insert_html( filename )
	
#	アルファベット、ピリオド、アンダーバー、ハイフン以外が含まれたら、エラーとする
	if (filename.match(/[^A-Za-z0-9\._-]/)) then
		raise "bad filename: " + filename
	end
	
	html = ""
	
	ary = IO.readlines(@conf['insert_html.htmlpath'].untaint + filename.untaint)
	ary.each do |line|
		html += line
	end
	%Q[#{html}]
end

#
# config
#
unless @resource_loaded then
	def insert_html_label
		"HTML挿入プラグイン"
	end
end

add_conf_proc( 'insert_html', insert_html_label ) do
	if @mode == 'saveconf' then
#		必ず"/"で終わるように保存
		htmlpath = @cgi.params['insert_html.htmlpath'][0]
		htmlpath += "/" if (not htmlpath.match(/\/$/))
		@conf['insert_html.htmlpath'] = htmlpath
		
	end
	<<-HTML
	<p>指定したHTMLファイルを読み込んで表示するプラグインです。</p>
	<h3>HTMLファイルの配置パスの指定</h3>
	<p>HTMLファイルが置かれているフォルダへのURLを指定します。<br>
	（最後は"/"で終わるように）</p>
	<p>安全のため、ここで指定したパス以外のファイルは参照できません。</p>
	<p><input type="text" name="insert_html.htmlpath" size="70" value="#{@conf['insert_html.htmlpath']}">
	<br>
	HTML
end
