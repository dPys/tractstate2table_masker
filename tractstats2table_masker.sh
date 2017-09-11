#!/bin/bash
TRACT=CST
filelines_tracts='lh.cst_AS_avg33_mni_bbr rh.cst_AS_avg33_mni_bbr'

for PARTIC in `ls /work/04171/dpisner/data/ABM/TRACULA/tractography_output | grep ^s`; do
    for tract in $filelines_tracts; do
        rm -rf /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask 2>/dev/null
        rm /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/"$tract"_pickle 2>/dev/null
        mkdir -p /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask 2>/dev/null
        tractstats2table_masker --inputs /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/dpath/$tract/pathstats.byvoxel.txt --byvoxel --byvoxel-measure=FA --tablefile /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask/"$tract".table -m /work/04171/dpisner/data/ABM/group_analysis/4_TBSS_MDD_V_HEALTHY/stats/"$PARTIC"_FA_tbss_fill_bin.nii.gz -v
    done
done

TRACT=SLFT
filelines_tracts='lh.slft_PP_avg33_mni_bbr rh.slft_PP_avg33_mni_bbr'

for PARTIC in `ls /work/04171/dpisner/data/ABM/TRACULA/tractography_output | grep ^s`; do
    for tract in $filelines_tracts; do
        rm -rf /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask 2>/dev/null
        rm /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/"$tract"_pickle 2>/dev/null
        mkdir -p /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask 2>/dev/null
        tractstats2table_masker --inputs /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/dpath/$tract/pathstats.byvoxel.txt --byvoxel --byvoxel-measure=FA --tablefile /work/04171/dpisner/data/ABM/TRACULA/tractography_output/"$PARTIC"/tables_"$TRACT"_mask/"$tract".table -m /work/04171/dpisner/data/ABM/group_analysis/5_TBSS_MDD_rumination/stats/"$PARTIC"_FA_grot_bin.nii.gz -v
    done
done

#!/usr/bin/env python
import glob
import os
import pandas as pd
import numpy as np

###
working_path = r'/work/04171/dpisner/data/ABM/TRACULA/tractography_output' # use your path
tracts = ['lh.slft_PP_avg33_mni_bbr','rh.slft_PP_avg33_mni_bbr']
#tracts = ['lh.cst_AS_avg33_mni_bbr', 'rh.cst_AS_avg33_mni_bbr']
###

df = pd.DataFrame()
#subj_dirs = os.listdir(working_path)
#subj_dirs = [i for i in os.listdir(working_path) if len(i) <= 4]
subj_dirs = [i for i in os.listdir(working_path) if len(i) <= 4 and not i.startswith('s9')]
subj_dirs.sort()

df['id'] = range(1, len(subj_dirs) + 1)
df['id'] = df['id'].astype('object')

j=0
for ID in subj_dirs:
    i=0
    df['id'][int(j)] = ID
    for tract in tracts:
        df[str(tract)] = np.nan
        df[str(tract)] = df[str(tract)].astype('object')
        i = i + 1
    j = j + 1

for ID in list(df['id']):
    allFiles = []
    for tract in tracts:
        path_name = working_path + '/' + ID + '/' + ID + '_' + tract + '_pickle'
        if os.path.isfile(path_name):
            allFiles.append(path_name)
        try:
            df_tmp = pd.read_pickle(path_name)
        except:
            print('No pickle available for ' + str(tract) + ' for ' + ID + '...')
            continue
        if df_tmp < 1:
            x=np.array(df['id'])
            ix = np.where(x==ID)[0][0]
            df[str(tract)][int(ix)] = df_tmp
        else:
            print('Irregular value of ' + str(df_tmp) + ' encountered. Continuing..')
            continue

out_path = working_path + '/output_SLFT.csv'
#out_path = working_path + '/output_CST.csv'
df.to_csv(out_path)
