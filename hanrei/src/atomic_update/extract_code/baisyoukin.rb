#coding:utf-8
#賠償金を主文から抽出
require '/opt/atomic_update/extract_code/class/baisyoukin_class.rb'
require '/opt/atomic_update/create_atomic.rb'
require '/opt/solr_test_server/sort_hanketubun.rb'

SOURCE_ROOT = "/opt/atomic_update/meta_data/"
REGI_ROOT = "/opt/atomic_update/meta_data/"
SOURCE_ROOT = ARGV[0]
REGI_ROOT = ARGV[1]
PATTERN = '**/**/*.xml'
#PATTERN = "**/syubun/**/**/*.xml"
#############################################
#						main
#############################################
baisyou = Calc_Baisyou.new()
facet = Facet_Bunruri.new()
sort_hanketubun = Sort_Hanketubun.new()
update_frg = 0			#賠償金が抽出出来たら、update_frg = 1
########################################################
#										主文抽出
########################################################
Dir.chdir(SOURCE_ROOT)
Dir.glob(PATTERN) do |file|
	puts '----------------------'
	puts REGI_ROOT
	syubun = ''
	id = file.split('/')[-1].delete('.xml')
	s_file = open(file,'r')
	s_file.each_line{|l|
		syubun += l
	}
	if /<field name="syubun" update="set">/ =~ syubun
		syubun = $'.gsub(/<\/field><\/doc><\/add>/,'')
	end
	########################################################
	#								主文から賠償金抽出
	########################################################
	total,total_man,total_other = baisyou.calc_baisyou(syubun)
	parent_facet,child_facet = facet.calc_facet(total_man,total_other)
	puts total
	puts parent_facet
	puts child_facet
	if parent_facet != "" and child_facet != "" and total != "0円"
		update_frg = 1
	else
		update_frg = 0
	end
	
	########################################################
	#						アトミックファイル作成
	########################################################
	if update_frg == 1 then
		baisyoukin_atomic = Atomic_Update.new()
		baisyoukin_atomic.set_unique(id)
		baisyoukin_atomic.set_update("baisyoukin_raw",total)
		baisyoukin_atomic.set_update("baisyoukin_parent",parent_facet)
		baisyoukin_atomic.set_update("baisyoukin_child",child_facet)
		path = sort_hanketubun.file_analysis(id,REGI_ROOT+"baisyoukin/")
		dest = path+id+".xml"
		baisyoukin_atomic.create_atomic_file(dest)
		update_frg = 0
	end
end
