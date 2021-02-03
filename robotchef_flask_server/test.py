import json
import numpy as np
import cv2

# class VideoCaptureYUV:
#     def __init__(self, filename, size):
#         self.height, self.width = size
#         self.frame_len = self.width * self.height * 3 / 2
#         self.f = open(filename, 'rb')
#         self.shape = (int(self.height*1.5), self.width)

#     def read_raw(self):
#         try:
#             raw = self.f.read(self.frame_len)
#             yuv = np.frombuffer(raw, dtype=np.uint8)
#             yuv = yuv.reshape(self.shape)
#         except Exception as e:
#             print str(e)
#             return False, None
#         return True, yuv

#     def read(self):
#         ret, yuv = self.read_raw()
#         if not ret:
#             return ret, yuv
#         bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_NV21)
#         return ret, bgr


import numpy as np
import cv2 as cv

npTmp = np.random.random((1024, 1024)).astype(np.float32)

npMat1 = np.stack([npTmp,npTmp],axis=2)
npMat2 = npMat1

cuMat1 = cv.cuda_GpuMat()
cuMat2 = cv.cuda_GpuMat()
cuMat1.upload(npMat1)
cuMat2.upload(npMat2)

print(cv.cuda.gemm(cuMat1, cuMat2,1,None,0,None,1))
print(cv.gemm(npMat1,npMat2,1,None,0,None,1))