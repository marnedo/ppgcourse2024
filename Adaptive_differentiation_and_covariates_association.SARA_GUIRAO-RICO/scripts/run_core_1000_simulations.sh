#!/bin/bash

mkdir simulations_core                                                                                                                        
# run BayPass (CORE Model) with the 1,000 PODs as input
../software/baypass_public/sources/g_baypass -npop 52 -gfile ./input/G.hgdp_pods_1000 -outprefix ./simulations_core/hgdp_pod_1000
