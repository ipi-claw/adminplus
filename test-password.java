import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class test-password {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // 数据库中的密码哈希值
        String adminHash = "$2b$12$z.ZQW6EC9pcP1LDxw043fOdCzQ9ByPx12Fv9VSTzysKWCCnUspjK6";
        String testHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH";

        // 测试各种可能的密码
        String[] passwords = {
            "admin123",
            "admin",
            "password",
            "123456"
        };

        System.out.println("测试 admin 用户密码：");
        for (String pwd : passwords) {
            System.out.println("  " + pwd + ": " + encoder.matches(pwd, adminHash));
        }

        System.out.println("\n测试 test 用户密码：");
        for (String pwd : passwords) {
            System.out.println("  " + pwd + ": " + encoder.matches(pwd, testHash));
        }

        // 生成 admin123 的哈希值
        System.out.println("\n生成 admin123 的哈希值：");
        for (int i = 0; i < 3; i++) {
            System.out.println("  " + encoder.encode("admin123"));
        }
    }
}