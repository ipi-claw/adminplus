package com.adminplus.service.impl;

import com.adminplus.service.CaptchaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 验证码服务实现
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CaptchaServiceImpl implements CaptchaService {

    private final StringRedisTemplate redisTemplate;

    // 验证码过期时间（5分钟）
    private static final long CAPTCHA_EXPIRE_MINUTES = 5;

    // 验证码 Redis 键前缀
    private static final String CAPTCHA_KEY_PREFIX = "captcha:";

    // 验证码字符集
    private static final String CAPTCHA_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    // 验证码长度
    private static final int CAPTCHA_LENGTH = 4;

    // 图片宽度
    private static final int IMAGE_WIDTH = 120;

    // 图片高度
    private static final int IMAGE_HEIGHT = 40;

    private final Random random = new Random();

    @Override
    public CaptchaResult generateCaptcha() {
        // 生成验证码文本
        String captchaCode = generateCaptchaCode();

        // 生成验证码ID
        String captchaId = UUID.randomUUID().toString();

        // 保存到 Redis
        String redisKey = CAPTCHA_KEY_PREFIX + captchaId;
        redisTemplate.opsForValue().set(redisKey, captchaCode, CAPTCHA_EXPIRE_MINUTES, TimeUnit.MINUTES);

        // 生成验证码图片
        BufferedImage image = generateCaptchaImage(captchaCode);

        log.info("生成验证码: ID={}, 代码={}", captchaId, captchaCode);

        return new CaptchaResult(captchaId, captchaCode, image);
    }

    @Override
    public boolean validateCaptcha(String captchaId, String captchaCode) {
        if (captchaId == null || captchaId.isEmpty() || captchaCode == null || captchaCode.isEmpty()) {
            return false;
        }

        String redisKey = CAPTCHA_KEY_PREFIX + captchaId;
        String storedCode = redisTemplate.opsForValue().get(redisKey);

        if (storedCode == null) {
            log.warn("验证码不存在或已过期: ID={}", captchaId);
            return false;
        }

        // 验证成功后删除验证码
        boolean isValid = storedCode.equalsIgnoreCase(captchaCode);
        if (isValid) {
            redisTemplate.delete(redisKey);
            log.info("验证码验证成功: ID={}", captchaId);
        } else {
            log.warn("验证码验证失败: ID={}, 输入={}, 正确={}", captchaId, captchaCode, storedCode);
        }

        return isValid;
    }

    /**
     * 生成验证码文本
     */
    private String generateCaptchaCode() {
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CAPTCHA_LENGTH; i++) {
            code.append(CAPTCHA_CHARS.charAt(random.nextInt(CAPTCHA_CHARS.length())));
        }
        return code.toString();
    }

    /**
     * 生成验证码图片
     */
    private BufferedImage generateCaptchaImage(String code) {
        BufferedImage image = new BufferedImage(IMAGE_WIDTH, IMAGE_HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();

        // 设置抗锯齿
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        // 填充背景
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);

        // 绘制干扰线
        for (int i = 0; i < 5; i++) {
            g.setColor(getRandomColor());
            g.drawLine(random.nextInt(IMAGE_WIDTH), random.nextInt(IMAGE_HEIGHT),
                    random.nextInt(IMAGE_WIDTH), random.nextInt(IMAGE_HEIGHT));
        }

        // 绘制干扰点
        for (int i = 0; i < 50; i++) {
            g.setColor(getRandomColor());
            g.fillOval(random.nextInt(IMAGE_WIDTH), random.nextInt(IMAGE_HEIGHT), 2, 2);
        }

        // 绘制验证码
        g.setFont(new Font("Arial", Font.BOLD, 28));
        for (int i = 0; i < code.length(); i++) {
            g.setColor(getRandomColor());
            // 随机旋转和位移
            double angle = (random.nextInt(30) - 15) * Math.PI / 180;
            g.rotate(angle, 20 + i * 25, IMAGE_HEIGHT / 2);
            g.drawString(String.valueOf(code.charAt(i)), 20 + i * 25, IMAGE_HEIGHT / 2 + 10);
            g.rotate(-angle, 20 + i * 25, IMAGE_HEIGHT / 2);
        }

        g.dispose();
        return image;
    }

    /**
     * 获取随机颜色
     */
    private Color getRandomColor() {
        return new Color(random.nextInt(256), random.nextInt(256), random.nextInt(256));
    }
}