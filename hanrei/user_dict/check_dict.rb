# -* coding: UTF-8 -*-
require 'kconv'

check = Hash.new(0)
file = open('/opt/userdict_ja_new.txt','r')
file.each_line{|l|
	kazukana_frg = 0
	a,b,c,d = l.split(',')
	check[a] += 1
}
for k,v in check do
	if v >= 2
		puts k
	else
		next
	end
end
#file = open('/opt/userdict_ja.txt','r')
#file.each_line{|l|
#	a,b,c,d = l.split(',')
#	if check[a] >= 2
#		check[a] -= 1
#		next
#	else
#		puts a+","+b+","+c+","+d
#	end
#}

