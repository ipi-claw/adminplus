package com.adminplus.service;

import java.awt.image.BufferedImage;

/**
 * 验证码服务接口
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
public interface CaptchaService {

    /**
     * 生成验证码
     *
     * @return 验证码图片和文本
     */
    CaptchaResult generateCaptcha();

    /**
     * 验证验证码
     *
     * @param captchaId 验证码ID
     * @param captchaCode 用户输入的验证码
     * @return 是否验证通过
     */
    boolean validateCaptcha(String captchaId, String captchaCode);

    /**
     * 验证码结果
     */
    record CaptchaResult(
            String captchaId,
            String captchaCode,
            BufferedImage image
    ) {
    }
}