const js = require('@eslint/js');
const tsParser = require('@typescript-eslint/parser');
const tsPlugin = require('@typescript-eslint/eslint-plugin');
const securityPlugin = require('eslint-plugin-security');
const prettierConfig = require('eslint-config-prettier');

module.exports = [
    {
        ignores: ['dist/**', 'node_modules/**', 'coverage/**', '*.js', 'uploads/**'],
    },
    js.configs.recommended,
    {
        files: ['src/**/*.ts', 'tests/**/*.ts'],
        languageOptions: {
            parser: tsParser,
            parserOptions: {
                ecmaVersion: 2022,
                sourceType: 'module',
                project: './tsconfig.json',
                tsconfigRootDir: __dirname,
            },
        },
        plugins: {
            '@typescript-eslint': tsPlugin,
            security: securityPlugin,
        },
        rules: {
            ...tsPlugin.configs.recommended.rules,
            ...securityPlugin.configs.recommended.rules,
            ...prettierConfig.rules,
            'no-undef': 'off',
            'no-case-declarations': 'off',
            '@typescript-eslint/no-explicit-any': 'warn',
            '@typescript-eslint/explicit-function-return-type': 'off',
            '@typescript-eslint/explicit-module-boundary-types': 'off',
            '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_', caughtErrors: 'none' }],
            '@typescript-eslint/no-require-imports': 'off',
            '@typescript-eslint/no-empty-object-type': 'off',
            '@typescript-eslint/no-unsafe-function-type': 'off',
            '@typescript-eslint/ban-ts-comment': 'off',
            'no-console': ['warn', { allow: ['warn', 'error'] }],
            'security/detect-object-injection': 'off',
            'security/detect-non-literal-fs-filename': 'off',
        },
    },
];
