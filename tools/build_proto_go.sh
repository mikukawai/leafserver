#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PROJECT_PATH/deps/lib/
PROTOC=$PROJECT_PATH/deps/bin/protoc
CODE_PATH=$PROJECT_PATH/src
CLANG_FORMAT="clang-format -style=\"{BasedOnStyle: google, ColumnLimit: 200}\""

cd $CODE_PATH

# out protos
out_protos=(cl)
#if [ -f $PROJECT_PATH/src/kit/gateway/protos/out/cg.proto ]; then
#  #cp $PROJECT_PATH/src/kit/gateway/protos/out/cg.proto $PROJECT_PATH/protos/out/
#  sed -i "1i\//文件从Gateway中Copy, 禁止修改" $PROJECT_PATH/protos/out/cg.proto
#  sed -i '4ioption go_package = "app/protos/out/cg";' $PROJECT_PATH/protos/out/cg.proto
#fi

OUTPATH=$PROJECT_PATH/src/app/protos/out/cl/
for i in ${out_protos[@]}
do
  proto_path=$PROJECT_PATH/protos/out
  eval "$CLANG_FORMAT -i $proto_path/$i.proto"
	if $PROTOC -I=$proto_path --go_out=./ $proto_path/$i.proto; then
	#if $PROTOC -I=$proto_path --go_out=paths=source_relative:./ $proto_path/$i.proto; then
		echo build success $i.proto
	else
		echo build failed $i.proto
    exit 1
	fi
done

# in protos
#in_protos=(db g2l r2l log md p2l config l2c censor2l r2c cr)

#for i in ${in_protos[@]}
#do
#  proto_path=$PROJECT_PATH/protos/in
#  eval "$CLANG_FORMAT -i $proto_path/$i.proto"
#	if $PROTOC -I=$proto_path -I=$PROJECT_PATH/protos/out --gofast_out=./ $proto_path/$i.proto; then
#		echo build success $i.proto
#	else
#		echo build failed $i.proto
#    exit 1
#	fi
#done

# gm protos
#gm_protos=(gm account)
#
#for i in ${gm_protos[@]}
#do
#  proto_path=$PROJECT_PATH/protos/in
#  eval "$CLANG_FORMAT -i $proto_path/$i.proto"
#	if $PROTOC -I=$proto_path -I=$PROJECT_PATH/protos/out --gofast_out=plugins=grpc:. $proto_path/$i.proto; then
#		echo build success $i.proto
#	else
#		echo build failed $i.proto
#    exit 1
#	fi
#done

# text censor protos
#censor_protos=(censor)
#
#for i in ${censor_protos[@]}
#do
#  proto_path=$PROJECT_PATH/protos/censor/text_censor
#  eval "$CLANG_FORMAT -i $proto_path/$i.proto"
#	if $PROTOC -I=$proto_path -I=$PROJECT_PATH/protos/out --gofast_out=plugins=grpc:. $proto_path/$i.proto; then
#		echo build success $i.proto
#	else
#		echo build failed $i.proto
#    exit 1
#	fi
#done

# proto clone
$PROJECT_PATH/tools/protoclone -pbgo=$PROJECT_PATH/src/app/protos/out/cl/cl.pb.go -skip=L2C_,C2L_ -enableLangTranslator=true
#$PROJECT_PATH/tools/protoclone -pbgo=$PROJECT_PATH/src/app/protos/in/db/db.pb.go
#$PROJECT_PATH/tools/protoclone -pbgo=$PROJECT_PATH/src/app/protos/in/cr/cr.pb.go

# proto cmd
#$PROJECT_PATH/tools/protocmd --package=cl --file=$PROJECT_PATH/src/app/protos/out/cl/cl.pb.go --message=L2C_,C2L_
#$PROJECT_PATH/tools/protocmd --package=l2c --file=$PROJECT_PATH/src/app/protos/in/l2c/l2c.pb.go --message=C2L_,L2C_

goimports -w $PROJECT_PATH/src/app/protos/out/cl
#goimports -w $PROJECT_PATH/src/server/protos/in/l2c

# cp r2l.go
#gofmt -w -s $PROJECT_PATH/protos/in/r2l_grpc.go
#cp -p $PROJECT_PATH/protos/in/r2l_grpc.go $PROJECT_PATH/src/app/protos/in/r2l/


# 对于一些配置文件(比如可配置活动，幸运抽奖)，需要同时在gmxml和proto定义
# 添加字段比较麻烦，而且容易出错，所以这里对proto添加一个 //$<XMLATTR> 注释
# 自动给这些proto message的字段添加 xml:"field_name,attr" tag
# 以便让这些结构同时支持gmxml，proto
#cat $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go | sed '/XMLATTR/,/^}$/s/json:"-"/json:"-" xml:"-"/' | sed '/XMLATTR/,/^}$/s/json:"\(.*\),omitempty"/json:"\1,omitempty" xml:"\1,attr"/' | sed '/XMLATTR/,/^}$/s/]\(.*\)xml:"\(.*\),attr"/]\1xml:"\2"/' | sed '/XMLATTR/,/^}$/s/Resource\(.*\)xml:"\(.*\),attr"/Resource\1xml:"\2"/' | sed '/XMLATTR/,/^}$/s/\(*[A-Z]\)\(.*\)xml:"\(.*\),attr"/\1\2xml:"\3"/' > $PROJECT_PATH/src/app/protos/out/cl/cl2.pb.go
#mv -f $PROJECT_PATH/src/app/protos/out/cl/cl2.pb.go $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go

#lineNum=0
#isXmlAttrState=0
#startXmlLine=0
#cat $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go | while read line;do
#	let lineNum++
#	if [[ "$line" = "//$<XMLATTR>" ]]; then
#					if [[ $isXmlAttrState = 1 ]]; then
#									echo "repeated xml attr state" $lineNum
#									exit 1
#					fi
#					let isXmlAttrState=1
#					let startXmlLine=${lineNum}
#  elif [[ "$line" = "}" ]]; then
#					if [[ $isXmlAttrState = 1 ]]; then
#									let isXmlAttrState=0
#									#echo $startXmlLine $lineNum
#									sed -i "${startXmlLine},${lineNum}"'{/\[]/!s/json:"\(.*\),omitempty"/json:"\1,omitempty" xml:"\1,attr"/}' $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go
#									sed -i "${startXmlLine},${lineNum}"'{/\[]/s/json:"\(.*\),omitempty"/json:"\1,omitempty" xml:"\1"/}' $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go
#									sed -i "${startXmlLine},${lineNum}"'s/json:"-"/json:"-" xml:"-"/' $PROJECT_PATH/src/app/protos/out/cl/cl.pb.go
#					fi
#	fi
#done
