/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#define WAKE_LOCK_PATH "/sys/power/wake_lock"
#define WAKE_UNLOCK_PATH "/sys/power/wake_unlock"

extern "C" {

int mtk_acquire_wake_lock(const char* id) {
    if (!id) return -EINVAL;
    int fd = open(WAKE_LOCK_PATH, O_WRONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    ssize_t ret = write(fd, id, strlen(id));
    close(fd);
    return ret >= 0 ? 0 : -errno;
}

int mtk_release_wake_lock(const char* id) {
    if (!id) return -EINVAL;
    int fd = open(WAKE_UNLOCK_PATH, O_WRONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    ssize_t ret = write(fd, id, strlen(id));
    close(fd);
    return ret >= 0 ? 0 : -errno;
}

int acquire_wake_lock(int lock, const char* id) {
    (void)lock;
    return mtk_acquire_wake_lock(id);
}

int release_wake_lock(const char* id) {
    return mtk_release_wake_lock(id);
}

}
