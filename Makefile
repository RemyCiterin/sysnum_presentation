.PHONY: gpu
gpu:
	fujprog -t gpu.bit

.PHONY: doom
doom:
	fujprog -t doom.bit

.PHONY: ray_tracing
ray_tracing:
	fujprog -t ray_tracing.bit

.PHONY: unix
unix:
	fujprog -t unix.bit
