# Compiler
CXX?=g++
EXT?=so

# Locations of the dependencies
KALDI_ROOT?=$(HOME)/kaldi
KALDI_INCLUDE?=$(KALDI_ROOT)/include/kaldi
KALDI_LIB?=$(KALDI_ROOT)/lib
OPENFST_ROOT?=$(HOME)/openfst
OPENFST_INCLUDE?=$(OPENFST_ROOT)/include
OPENFST_LIB?=$(OPENFST_ROOT)/lib
OPENBLAS_ROOT?=$(HOME)/openblas
OPENBLAS_INCLUDE?=$(OPENBLAS_ROOT)/include
OPENBLAS_LIB?=$(OPENBLAS_ROOT)/lib
F2C_LIB?=$(HOME)/f2c

MKL_ROOT?=/opt/intel/mkl
CUDA_ROOT?=/usr/local/cuda
USE_SHARED?=0

# Math libraries
HAVE_OPENBLAS_CLAPACK?=1
HAVE_MKL?=0
HAVE_ACCELERATE=0
HAVE_CUDA?=0

# Extra
EXTRA_CFLAGS?=
EXTRA_LDFLAGS?=
OUTDIR?=.

VOSK_SOURCES= \
	recognizer.cc \
	language_model.cc \
	model.cc \
	spk_model.cc \
	vosk_api.cc \
	postprocessor.cc

VOSK_HEADERS= \
	recognizer.h \
	language_model.h \
	model.h \
	spk_model.h \
	vosk_api.h \
	postprocessor.h

CFLAGS=-g -O3 -std=c++17 -Wno-deprecated-declarations -fPIC -DFST_NO_DYNAMIC_LINKING -I. -I$(KALDI_INCLUDE) -I$(OPENFST_INCLUDE) $(EXTRA_CFLAGS)

ifeq ($(USE_SHARED), 0)
	LIBS = \
		$(KALDI_LIB)/online2/kaldi-online2.a \
		$(KALDI_LIB)/decoder/kaldi-decoder.a \
		$(KALDI_LIB)/ivector/kaldi-ivector.a \
		$(KALDI_LIB)/gmm/kaldi-gmm.a \
		$(KALDI_LIB)/tree/kaldi-tree.a \
		$(KALDI_LIB)/feat/kaldi-feat.a \
		$(KALDI_LIB)/lat/kaldi-lat.a \
		$(KALDI_LIB)/lm/kaldi-lm.a \
		$(KALDI_LIB)/rnnlm/kaldi-rnnlm.a \
		$(KALDI_LIB)/hmm/kaldi-hmm.a \
		$(KALDI_LIB)/nnet3/kaldi-nnet3.a \
		$(KALDI_LIB)/transform/kaldi-transform.a \
		$(KALDI_LIB)/cudamatrix/kaldi-cudamatrix.a \
		$(KALDI_LIB)/matrix/kaldi-matrix.a \
		$(KALDI_LIB)/fstext/kaldi-fstext.a \
		$(KALDI_LIB)/util/kaldi-util.a \
		$(KALDI_LIB)/base/kaldi-base.a \
		$(OPENFST_LIB)/libfst.a \
		$(OPENFST_LIB)/libfstngram.a
else
	LDFLAGS=-L$(OPENFST_LIB) -L$(KALDI_LIB) \
			-lkaldi-online2 -lkaldi-decoder -lkaldi-ivector -lkaldi-gmm -lkaldi-tree \
			-lkaldi-feat -lkaldi-lat -lkaldi-lm -lkaldi-rnnlm -lkaldi-hmm -lkaldi-nnet3 \
			-lkaldi-transform -lkaldi-cudamatrix -lkaldi-matrix -lkaldi-fstext \
			-lkaldi-util -lkaldi-base -lfst -lfstngram
endif

ifeq ($(HAVE_OPENBLAS_CLAPACK), 1)
	CFLAGS += -I$(OPENBLAS_INCLUDE)
	ifeq ($(USE_SHARED), 0)
		LIBS += \
			$(OPENBLAS_LIB)/libopenblas.a \
			$(OPENBLAS_LIB)/liblapack.a \
			$(OPENBLAS_LIB)/libblas.a \
			$(OPENBLAS_LIB)/libf2c.a
	else
		LDFLAGS += -L$(OPENBLAS_LIB) -L$(F2C_LIB) -lopenblas -llapack -lblas -lf2c
	endif
endif

# ifeq ($(HAVE_MKL), 1)
# 	CFLAGS += -DHAVE_MKL=1 -I$(MKL_ROOT)/include
# 	LDFLAGS += -L$(MKL_ROOT)/lib/intel64 -Wl,-rpath=$(MKL_ROOT)/lib/intel64 -lmkl_rt -lmkl_intel_lp64 -lmkl_core -lmkl_sequential
# endif

# ifeq ($(HAVE_ACCELERATE), 1)
# 	LDFLAGS += -framework Accelerate
# endif

# ifeq ($(HAVE_CUDA), 1)
# 	VOSK_SOURCES += batch_recognizer.cc batch_model.cc
# 	VOSK_HEADERS += batch_recognizer.h batch_model.h

# 	CFLAGS+=-DHAVE_CUDA=1 -I$(CUDA_ROOT)/include

# 	LIBS := \
# 		$(KALDI_LIB)/cudadecoder/kaldi-cudadecoder.a \
# 		$(KALDI_LIB)/cudafeat/kaldi-cudafeat.a \
# 		$(LIBS)

# 	LDFLAGS += -L$(CUDA_ROOT)/lib64 -lcuda -lcublas -lcusparse -lcudart -lcurand -lcufft -lcusolver -lnvToolsExt
# endif

all: $(OUTDIR)/libvosk.$(EXT)

$(OUTDIR)/libvosk.$(EXT): $(VOSK_SOURCES:%.cc=$(OUTDIR)/%.o) $(LIBS)
	echo $(LDFLAGS)
	$(CXX) --shared -s -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS)

$(OUTDIR)/%.o: %.cc $(VOSK_HEADERS)
	$(CXX) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.so *.dll
