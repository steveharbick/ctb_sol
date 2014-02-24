
# parameters for generating document term matrix
nb_word_grams_max=3
nb_char_grams_max1=4
nb_char_grams_max2=6
rare_grams_thres=15

# parameters for all RF models
RF_maxnodes=NULL
RF_nodesize=10

# parameters for RF used for feature selection
RF_4fs_ntree=1000
RF_4fs_mtry=300
# parameters for RF used for feature selection
RF_pfs_ntree=1000
RF_pfs_mtry=50

# parameters for elasticnet
GLMNET_alpha=0.5
GLMNET_standardize=FALSE

# parameters for GBM
GBM_maxtrees=10000
GBM_treestep=100
GBM_shrinkage=0.01
GBM_bag.fraction=0.75
GBM_n.minobsinnode=10
GBM_local_protection_threshold=0.0002

# parameters for SVM linear
SVM_lin_cost_i=0.01
SVM_lin_cost_var=10^0.125
SVM_lin_step_max=15

# parameters for SVM radial
SVM_rad_gamma_i=0.01*10^.5
SVM_rad_cost_i=1
SVM_rad_step_max=12
SVM_rad_cost_var=10^.25
SVM_rad_gamma_var=10^.25

Store(nb_word_grams_max,nb_char_grams_max1,nb_char_grams_max2,rare_grams_thres,
      RF_maxnodes,RF_nodesize,
      RF_4fs_ntree,RF_4fs_mtry,
      RF_pfs_ntree,RF_pfs_mtry,
      GLMNET_alpha,GLMNET_standardize,
      GBM_maxtrees,GBM_treestep,
      GBM_shrinkage,GBM_bag.fraction,GBM_n.minobsinnode,
      GBM_local_protection_threshold,
      SVM_lin_cost_i,SVM_lin_cost_var,SVM_lin_step_max,
      SVM_rad_gamma_i,SVM_rad_cost_i,SVM_rad_step_max,
      SVM_rad_cost_var,SVM_rad_gamma_var)
