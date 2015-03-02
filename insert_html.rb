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
	
#	����ե��٥åȡ��ԥꥪ�ɡ���������С����ϥ��ե�ʳ����ޤޤ줿�顢���顼�Ȥ���
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
		"HTML�����ץ饰����"
	end
end

add_conf_proc( 'insert_html', insert_html_label ) do
	if @mode == 'saveconf' then
#		ɬ��"/"�ǽ����褦����¸
		htmlpath = @cgi.params['insert_html.htmlpath'][0]
		htmlpath += "/" if (not htmlpath.match(/\/$/))
		@conf['insert_html.htmlpath'] = htmlpath
		
	end
	<<-HTML
	<p>���ꤷ��HTML�ե�������ɤ߹����ɽ������ץ饰����Ǥ���</p>
	<h3>HTML�ե���������֥ѥ��λ���</h3>
	<p>HTML�ե����뤬�֤���Ƥ���ե�����ؤ�URL����ꤷ�ޤ���<br>
	�ʺǸ��"/"�ǽ����褦�ˡ�</p>
	<p>�����Τ��ᡢ�����ǻ��ꤷ���ѥ��ʳ��Υե�����ϻ��ȤǤ��ޤ���</p>
	<p><input type="text" name="insert_html.htmlpath" size="70" value="#{@conf['insert_html.htmlpath']}">
	<br>
	HTML
end
