#!/bin/bash

mkdir simulations_core                                                                                                                        
# run BayPass (CORE Model) with the 10,000 PODs as input
../software/baypass_public/sources/g_baypass -npop 52 -gfile ./results_core/G.hgdp_pods_10000 -outprefix ./simulations_core/hgdp_pod_10000
