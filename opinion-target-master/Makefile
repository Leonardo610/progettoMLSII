###################################################################################################
## Experiments for Baseline
###################################################################################################
cellphone-baseline:
	rm -f baseline/*.xml
	cd baseline; python semeval_base.py --train ../evaluation/Laptops_Train_v2.xml --task 1

yelp-data-baseline:
	rm -f baseline/*.xml
	cd baseline; python semeval_base.py --train ../evaluation/Restaurants_Train_v2.xml --task 5

###################################################################################################
## Experiments for Conditional Random Field
###################################################################################################
prepare-dataset:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFfile -Dexec.args="evaluation/Restaurants_Train_v2.xml yelp-data-train.tsv"
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFfile -Dexec.args="evaluation/yelp-data_test.xml yelp-data-test.tsv"
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFfile -Dexec.args="evaluation/Laptop_Train_v2.xml cellphone-train.tsv"	
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFfile -Dexec.args="evaluation/cellphones_test.xml cellphone-test.tsv"	

evaluate-yelp-data:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppOpinionTarget \
		-Dexec.args="yelp-data-model.ser.gz yelp-data-train.tsv evaluation/yelp-data_test.xml yelp-data-test-predict.tsv"
	paste yelp-data-test.tsv yelp-data-test-predict.tsv | cut -f1,3,5 > yelp-data-evaluate.tsv
	perl conlleval.pl -d "\t" < yelp-data-evaluate.tsv

###################################################################################################
## Experiments for Recurrent Neural Network
###################################################################################################	
CELLPHONE_TRAIN=evaluation/Laptop_Train_v2.xml
CELLPHONE_TEST=evaluation/cellphones_test.xml

YELPDATA_TRAIN=evaluation/Restaurants_Train_v2.xml
YELPDATA_TEST=evaluation/yelp-data_test.xml

embed=Senna
ifeq (${embed}, Google)
	EMBEDDIING_FILE=embeddings/google-news/GoogleNews-vectors-negative300.bin.gz
else
	ifeq (${embed}, Amazon)
		EMBEDDIING_FILE=embeddings/amazon/vectors-300.txt
	else
		EMBEDDIING_FILE=embeddings/senna
	endif
endif

cellphone-json:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppPrepareRnnDataset \
	-Dexec.args="-t ${CELLPHONE_TRAIN} -r 0.9 -s ${CELLPHONE_TEST} -o cellphone-json-${embed}.txt -e ${EMBEDDIING_FILE} -p ${embed}"
	
yelp-data-json:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppPrepareRnnDataset \
	-Dexec.args="-t ${YELPDATA_TRAIN} -r 0.9 -s ${YELPDATA_TEST} -o yelp-data-json-${embed}.txt -e ${EMBEDDIING_FILE} -p ${embed}"

# Example: make run-rnn dataset=laptop embed=Senna type=elman window=3 nhidden=100 dimension=50 init=true
run-rnn:
	python main.py ${dataset}-json-${embed}.txt ${type} ${dataset}-${type}-${embed}-${window}-${nhidden}-${dimension} ${window} ${nhidden} ${dimension} ${init}

###################################################################################################
## Experiments for CRFsuite on Word Embeddings
###################################################################################################	
run-word2vec:
	cd word2vec; ./word2vec -train ${datafile} -output vectors-${size}.txt -cbow 0 -size ${size} -window 5 -negative 0 -hs 1 -sample 1e-3 -threads 12 -binary 0
	@echo "[INFO] word2vec is finished."

cellphone-features:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFVectorFile -Dexec.args="${CELLPHONE_TRAIN} ${EMBEDDIING_FILE} ${embed} cellphone-train.tsv cellphone-train.con"
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFVectorFile -Dexec.args="${CELLPHONE_TEST} ${EMBEDDIING_FILE} ${embed} cellphone-test.tsv cellphone-test.con"
	cat cellphone-train.tsv | ./absa.py -s '\t' > cellphone-train.bin
	cat cellphone-test.tsv | ./absa.py -s '\t' > cellphone-test.bin
	cut -f 2- cellphone-train.bin > cellphone-train-bool.tmp
	cut -f 2- cellphone-test.bin > cellphone-test-bool.tmp
	paste cellphone-train.con cellphone-train-bool.tmp | sed 's/^\t$///g' > cellphone-train.bc
	paste cellphone-test.con cellphone-test-bool.tmp | sed 's/^\t$///g' > cellphone-test.bc

yelp-data-features:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFVectorFile -Dexec.args="${YELPDATA_TRAIN} ${EMBEDDIING_FILE} ${embed} yelp-data-train.tsv yelp-data-train.con"
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppCreateCRFVectorFile -Dexec.args="${YELPDATA_TEST} ${EMBEDDIING_FILE} ${embed} yelp-data-test.tsv yelp-data-test.con"
	cat yelp-data-train.tsv | ./absa.py -s '\t' > yelp-data-train.bin
	cat yelp-data-test.tsv | ./absa.py -s '\t' > yelp-data-test.bin
	cut -f 2- yelp-data-train.bin > yelp-data-train-bool.tmp
	cut -f 2- yelp-data-test.bin > yelp-data-test-bool.tmp
	paste yelp-data-train.con yelp-data-train-bool.tmp | sed 's/^\t$///g' > yelp-data-train.bc
	paste yelp-data-test.con yelp-data-test-bool.tmp | sed 's/^\t$///g' > yelp-data-test.bc

#type=bin(binary) or con(continuous) or bc (binary-continuous)
run-crfsuite:
	#crfsuite learn -m ${dataset}-crfsuite.mdl ${dataset}-train.${type}
	crfsuite learn -a l2sgd -p c2=2.0 -p feature.possible_transitions=1 -p feature.possible_states=1 -m ${dataset}-crfsuite.mdl ${dataset}-train.${type}
	#crfsuite learn -a lbfgs -p c2=1 -p feature.possible_transitions=1 -p feature.possible_states=1 -m ${dataset}-crfsuite.mdl ${dataset}-train.${type}
	crfsuite tag -r -m ${dataset}-crfsuite.mdl ${dataset}-test.${type} > ${dataset}-result.tsv
	paste ${dataset}-test.tsv ${dataset}-result.tsv > ${dataset}-combine.tsv
	cat ${dataset}-combine.tsv | cut -f1,2,4,5 | perl conlleval.pl -d "\t"

###################################################################################################
## Experiments for Cross Validation
###################################################################################################
prepare-folds:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppPrepareDataFolds \
	-Dexec.args="-f cross-validation/${dataset}.tsv -n 10 -d ${dataset}"

# example: make prepare-json dataset=dse fold=0 embed=senna
prepare-json:
	mvn -q compile exec:java -Dexec.mainClass=edu.cuhk.hccl.AppPrepareRnnJson \
	-Dexec.args="-t ${dataset}/train${fold}.tsv -r 0.9 -s ${dataset}/test${fold}.tsv -o ${dataset}-json-${embed}.txt -e ${EMBEDDIING_FILE} -p ${embed}"	
    
