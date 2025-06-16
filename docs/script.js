document.addEventListener('DOMContentLoaded', function() {
    // 标签页切换功能
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');

    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            // 移除所有活动状态
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabPanes.forEach(pane => pane.classList.remove('active'));

            // 添加当前活动状态
            this.classList.add('active');
            const tabId = this.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // 平滑滚动
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();

            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);

            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 100,
                    behavior: 'smooth'
                });
            }
        });
    });

    // 代码高亮效果（简化版）
    document.querySelectorAll('pre code').forEach(block => {
        // 为关键字添加颜色
        const keywords = ['const', 'var', 'try', 'defer', 'return', 'if', 'else', 'switch', 'case', 'for', 'while', 'fn', 'pub', 'struct', 'enum', 'import'];

        keywords.forEach(keyword => {
            const regex = new RegExp(`\\b${keyword}\\b`, 'g');
            block.innerHTML = block.innerHTML.replace(
                regex,
                `<span style="color: #ff79c6;">${keyword}</span>`
            );
        });

        // 为字符串添加颜色
        block.innerHTML = block.innerHTML.replace(
            /("|')(\\\\.|[^\\"'])*\1/g,
            '<span style="color: #f1fa8c;">$&</span>'
        );

        // 为注释添加颜色
        block.innerHTML = block.innerHTML.replace(
            /(\/\/.*)/g,
            '<span style="color: #6272a4;">$1</span>'
        );

        // 为函数添加颜色
        block.innerHTML = block.innerHTML.replace(
            /\b([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/g,
            '<span style="color: #50fa7b;">$1</span>('
        );
    });

    // 添加动画效果
    const animateElements = document.querySelectorAll('.feature-card, .step, .endpoint-table');

    // 简单的滚动动画
    function checkScroll() {
        animateElements.forEach(element => {
            const elementTop = element.getBoundingClientRect().top;
            const elementVisible = 150;

            if (elementTop < window.innerHeight - elementVisible) {
                element.classList.add('animate');
            }
        });
    }

    // 添加动画CSS
    const style = document.createElement('style');
    style.textContent = `
        .feature-card, .step, .endpoint-table {
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.6s ease, transform 0.6s ease;
        }

        .feature-card.animate, .step.animate, .endpoint-table.animate {
            opacity: 1;
            transform: translateY(0);
        }

        .feature-card:nth-child(2) {
            transition-delay: 0.1s;
        }

        .feature-card:nth-child(3) {
            transition-delay: 0.2s;
        }

        .feature-card:nth-child(4) {
            transition-delay: 0.3s;
        }

        .feature-card:nth-child(5) {
            transition-delay: 0.4s;
        }

        .feature-card:nth-child(6) {
            transition-delay: 0.5s;
        }

        .step:nth-child(2) {
            transition-delay: 0.1s;
        }

        .step:nth-child(3) {
            transition-delay: 0.2s;
        }

        .step:nth-child(4) {
            transition-delay: 0.3s;
        }
    `;
    document.head.appendChild(style);

    // 初始检查和滚动监听
    window.addEventListener('scroll', checkScroll);
    checkScroll();
});