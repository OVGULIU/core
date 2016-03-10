set(MESHES "/lore/dibanez/meshes"
    CACHE string
    "path to the meshes svn repo")
macro(splitfun TESTNAME PROG MODEL IN OUT PARTS FACTOR)
  math(EXPR OUTPARTS "${PARTS} * ${FACTOR}")
  add_test("${TESTNAME}"
    ${MPIRUN} ${MPIRUN_PROCFLAG} ${OUTPARTS}
    "${PROG}"
    "${MODEL}"
    "${IN}"
    "${OUT}"
    ${FACTOR})
endmacro()
macro(cook TESTNAME PROG PARTS FACTOR WORKDIR)
  math(EXPR OUTPARTS "${PARTS} * ${FACTOR}")
  add_test(NAME "${TESTNAME}"
    COMMAND ${MPIRUN} ${MPIRUN_PROCFLAG} ${OUTPARTS} "${PROG}"
    WORKING_DIRECTORY "${WORKDIR}")
endmacro()
macro(parma TESTNAME MDL IN OUT FACTOR METHOD APPROACH ISLOCAL PARTS)
  math(EXPR OUTPARTS "${PARTS} * ${FACTOR}")
  add_test("${TESTNAME}"
    ${MPIRUN} ${MPIRUN_PROCFLAG} ${OUTPARTS} "./ptnParma" 
    ${MDL} ${IN} ${OUT} ${FACTOR} ${METHOD} ${APPROACH} ${ISLOCAL}
  )
endmacro()
add_test(shapefun shapefun)
add_test(shapefun2 shapefun2)
add_test(bezierElevation bezierElevation)
add_test(bezierMesh bezierMesh)
add_test(bezierMisc bezierMisc)
add_test(bezierRefine bezierRefine)
add_test(bezierSubdivision bezierSubdivision)
add_test(bezierValidity bezierValidity)

add_test(align align)
add_test(eigen_test eigen_test)
add_test(integrate integrate)
add_test(qr_test qr)
add_test(base64 base64)

set(MDIR ${MESHES}/fun3d)
add_test(inviscid_ugrid
  ./from_ugrid
  "${MDIR}/inviscid_egg.b8.ugrid"
  "${MDIR}/inviscid_egg.dmg"
  "${MDIR}/inviscid_egg.smb")
splitfun(inviscid_split
  ./split
  "${MDIR}/inviscid_egg.dmg"
  "${MDIR}/inviscid_egg.smb"
  "${MDIR}/4/"
  1 4)
add_test(inviscid_ghost
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./ghost
  "${MDIR}/inviscid_egg.dmg"
  "${MDIR}/4/"
  "${MDIR}/vis")
set(MDIR ${MESHES}/pipe)
add_test(convert
  convert
  "${MDIR}/pipe.smd"
  "${MDIR}/pipe.sms"
  "pipe.smb")
add_test(verify_serial
  verify
  "${MDIR}/pipe.smd"
  "pipe.smb")
add_test(uniform_serial
  uniform
  "${MDIR}/pipe.smd"
  "pipe.smb"
  "pipe_unif.smb")
add_test(snap_serial
  snap
  "${MDIR}/pipe.smd"
  "pipe_unif.smb"
  "pipe.smb")
add_test(ma_serial
  ma_test
  "${MDIR}/pipe.smd"
  "pipe.smb")
add_test(tet_serial
  tetrahedronize
  "${MDIR}/pipe.smd"
  "pipe.smb"
  "tet.smb")
if (PCU_COMPRESS)
  set(MESHFILE "bz2:pipe_2_.smb")
else()
  set(MESHFILE "pipe_2_.smb")
endif()
splitfun(split_2
  ./split
  "${MDIR}/pipe.smd"
  "pipe.smb"
  ${MESHFILE}
  1 2)
add_test(refineX
  ${MPIRUN} ${MPIRUN_PROCFLAG} 2
  ./refine2x
  "${MDIR}/pipe.smd"
  ${MESHFILE}
  0
  "refXpipe/")
if(ENABLE_ZOLTAN)
  splitfun(split_4
    ./zsplit
    "${MDIR}/pipe.smd"
    ${MESHFILE}
    "pipe_4_.smb"
    2 2)
else()
  splitfun(split_4
    ./split
    "${MDIR}/pipe.smd"
    ${MESHFILE}
    "pipe_4_.smb"
    2 2)
endif()
add_test(verify_parallel
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./verify
  "${MDIR}/pipe.smd"
  "pipe_4_.smb")
add_test(vtxElmMixedBalance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./vtxElmMixedBalance
  "${MDIR}/pipe.dmg"
  "pipe_4_.smb")
if(ENABLE_ZOLTAN)
  add_test(ma_parallel
    ${MPIRUN} ${MPIRUN_PROCFLAG} 4
    ./ma_test
    "${MDIR}/pipe.smd"
    "pipe_4_.smb")
  add_test(tet_parallel
    ${MPIRUN} ${MPIRUN_PROCFLAG} 4
    ./tetrahedronize
    "${MDIR}/pipe.smd"
    "pipe_4_.smb"
    "tet.smb")
endif()
set(MDIR ${MESHES}/torus)
add_test(reorder
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./reorder
  "${MDIR}/torus.dmg"
  "${MDIR}/4imb/torus.smb"
  "torusBfs4p/")
add_test(balance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./balance
  "${MDIR}/torus.dmg"
  "${MDIR}/4imb/torus.smb"
  "${MDIR}/torusBal4p/")
add_test(gap
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./gap
  "${MDIR}/torus.dmg"
  "${MDIR}/torusBal4p/"
  "${MDIR}/torusOpt4p/")
if(ENABLE_ZOLTAN)
  add_test(zbalance
    ${MPIRUN} ${MPIRUN_PROCFLAG} 4
    ./zbalance
    "${MDIR}/torus.dmg"
    "${MDIR}/4imb/torus.smb"
    "torusZbal4p/")
endif()
add_test(ghostElement
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./ghostElement
  "${MDIR}/torus.dmg"
  "${MDIR}/4imb/torus.smb"
  "torusGhostEle4p/")

add_test(fixDisconnected
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./fixDisconnected
  "${MDIR}/torus.dmg"
  "${MDIR}/4imb/torus.smb"
  "torusDcFix4p/")
set(MDIR ${MESHES}/airFoilAfosr)
add_test(elmBalance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./elmBalance
  "${MDIR}/afosr.dmg"
  "${MDIR}/4imb/"
  "afosrBal4p/")
add_test(vtxBalance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./vtxBalance
  "${MDIR}/afosr.smd"
  "${MDIR}/4imb/"
  "afosrBal4p/")
add_test(vtxEdgeElmBalance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./vtxEdgeElmBalance
  "${MDIR}/afosr.smd"
  "${MDIR}/4imb/"
  "afosrBal4p/"
  "2"
  "1.10")
add_test(vtxElmBalance
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./vtxElmBalance
  "${MDIR}/afosr.dmg"
  "${MDIR}/4imb/"
  "afosrBal4p/")
add_test(parmaSerial
  ${MPIRUN} ${MPIRUN_PROCFLAG} 1
  ./vtxElmBalance
  "${MESHES}/cube/cube.dmg"
  "${MESHES}/cube/pumi670/cube.smb"
  "cubeBal.smb/")
set(MDIR ${MESHES}/cube)
if(ENABLE_ZOLTAN)
  parma(ptnParma_cube
    "${MDIR}/cube.dmg"
    "${MDIR}/pumi670/cube.smb"
    "ptnParmaCube/" 
    "4" "rib" "reptn" "1"
    1)
endif()
add_test(construct
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./construct
  "${MDIR}/cube.dmg"
  "${MDIR}/pumi7k/4/cube.smb")
set(MDIR ${MESHES}/spr)
add_test(spr_3D
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./spr_test
  "${MDIR}/spr.dmg"
  "${MDIR}/quadspr.smb"
  spr3D
  2)
add_test(spr_2D
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./spr_test
  "${MDIR}/square.dmg"
  "${MDIR}/square.smb"
  spr2D
  1)
set(MDIR ${MESHES}/nonmanifold)
add_test(nonmanif_verify
  ./verify
  "${MDIR}/nonmanifold.dmg"
  "${MDIR}/nonmanifold.smb")
splitfun(nonmanif_split
  ./split
  "${MDIR}/nonmanifold.dmg"
  "${MDIR}/nonmanifold.smb"
  "nonmanifold_2_.smb"
  1 2)
add_test(nonmanif_verify2
  ${MPIRUN} ${MPIRUN_PROCFLAG} 2
  ./verify
  "${MDIR}/nonmanifold.dmg"
  "nonmanifold_2_.smb")
set(MDIR ${MESHES}/fusion)
add_test(mkmodel_fusion
  mkmodel
  "${MDIR}/fusion.smb"
  "fusion.dmg")
splitfun(split_fusion
  ./split
  "fusion.dmg"
  "${MDIR}/fusion.smb"
  "fusion_2_.smb"
  1 2)
# the part count mismatch is intentional,
# this test runs on half its procs
if(ENABLE_ZOLTAN)
  add_test(adapt_fusion
    ${MPIRUN} ${MPIRUN_PROCFLAG} 4
    ./fusion
    "fusion_2_.smb")
endif()
add_test(fusion_field
  ${MPIRUN} ${MPIRUN_PROCFLAG} 2
  ./fusion2)
add_test(change_dim
  ./newdim)
set(MDIR ${MESHES}/upright)
add_test(parallel_meshgen
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./generate
  "${MDIR}/upright.smd"
  "67k")
add_test(adapt_meshgen
  ${MPIRUN} ${MPIRUN_PROCFLAG} 4
  ./ma_test
  "${MDIR}/upright.smd"
  "67k/")
add_test(ma_insphere
  ma_insphere)
set(MDIR ${MESHES}/curved)
add_test(curvedSphere
  curvetest
  "${MDIR}/sphere1.xmt_txt"
  "${MDIR}/sphere1_4.smb")
 add_test(curvedKova
  curvetest
  "${MDIR}/Kova.xmt_txt"
  "${MDIR}/Kova.smb")
if (PCU_COMPRESS)
  set(MDIR ${MESHES}/phasta/1-1-Chef-Tet-Part/run_sim)
  if (PHASTA_CHEF_ENABLED)
    cook(chefStream ${CMAKE_CURRENT_BINARY_DIR}/chefStream 1 1 ${MDIR})
    set(cmd 
      ${CMAKE_BINARY_DIR}/phasta/bin/checkphasta 
      ${MDIR}/1-procs_case/ 
      ${MESHES}/phasta/1-1-Chef-Tet-Part/good_phasta/
      0 1e-6)
    add_test(
      NAME compareChefStream
      COMMAND ${cmd}
      WORKING_DIRECTORY ${MDIR}
    )
  endif()
  cook(chef0 ${CMAKE_CURRENT_BINARY_DIR}/chef 1 1 ${MDIR})
  set(MDIR ${MESHES}/phasta/1-1-Chef-Tet-Part)
  add_test(NAME chef1
    COMMAND diff -r -x .svn run_sim/1-procs_case/ good_phasta/
    WORKING_DIRECTORY ${MDIR})
  add_test(NAME chef2
    COMMAND diff -r -x .svn out_mesh/ good_mesh/
    WORKING_DIRECTORY ${MDIR})
  set(MDIR ${MESHES}/phasta/2-1-Chef-Tet-Part/run_sim)
  if(ENABLE_ZOLTAN)
    cook(chef3 ${CMAKE_CURRENT_BINARY_DIR}/chef 1 2 ${MDIR})
    set(MDIR ${MESHES}/phasta/2-1-Chef-Tet-Part/4-2-Chef-Part/run_sim)
    cook(chef4 ${CMAKE_CURRENT_BINARY_DIR}/chef 2 2 ${MDIR})
    set(MDIR ${MESHES}/phasta/4-1-Chef-Tet-Part/run_sim)
    cook(chef5 ${CMAKE_CURRENT_BINARY_DIR}/chef 1 4 ${MDIR})
  endif()
  set(MDIR ${MESHES}/phasta/4-1-Chef-Tet-Part/4-4-Chef-Part-ts20/run_sim)
  cook(chef6 ${CMAKE_CURRENT_BINARY_DIR}/chef 4 1 ${MDIR})
  set(MDIR ${MESHES}/phasta/4-1-Chef-Tet-Part/4-4-Chef-Part-ts20)
  add_test(NAME chef7
    COMMAND diff -r -x .svn run_sim/4-procs_case/ good_phasta/
    WORKING_DIRECTORY ${MDIR})
  add_test(NAME chef8
    COMMAND diff -r -x .svn out_mesh/ good_mesh/
    WORKING_DIRECTORY ${MDIR})
  if(NOT ENABLE_THREADS)
    set(MDIR ${MESHES}/phasta/simModelAndAttributes)
    cook(chef9 ${CMAKE_CURRENT_BINARY_DIR}/chef 1 2 ${MDIR})
  endif()
  set(MDIR ${MESHES}/phasta/4-1-Chef-Tet-Part/4-4-Chef-Part-ts20/run)
  add_test(NAME chefReadUrPrep
    COMMAND ${MPIRUN} ${MPIRUN_PROCFLAG} 4
    ${CMAKE_CURRENT_BINARY_DIR}/chefReadUrPrep ../../../model.dmg bz2:../good_mesh/ adapt.inp
    WORKING_DIRECTORY "${MDIR}")
endif()
