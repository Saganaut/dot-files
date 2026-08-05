import love from 'eslint-config-love'
import prettier from 'eslint-config-prettier'
import tailwindcss from 'eslint-plugin-tailwindcss'
import simpleImportSort from 'eslint-plugin-simple-import-sort'
import tseslint from 'typescript-eslint'
import react from 'eslint-plugin-react'
import js from '@eslint/js'
import { FlatCompat } from '@eslint/eslintrc'
import path from 'path'
import { fileURLToPath } from 'url'
import globals from 'globals'
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
    baseDirectory: __dirname,
    resolvePluginsRelativeTo: __dirname,
})

export default [
    // ...tseslint.configs.recommended,

    love,
    ...tailwindcss.configs['flat/recommended'],
    ...compat.config({
        plugins: ['eslint-plugin-tailwindcss', 'react', 'react-hooks'],
        extends: [
            'plugin:react/recommended',
            'plugin:react-hooks/recommended',
            'plugin:tailwindcss/recommended',
        ],
    }),
    {
        files: ['**/*.js', '**/*.ts', '**/*.tsx'],
        languageOptions: {
            ecmaVersion: 'latest',
            // sourceType: "module",

            globals: {
                ...globals.browser,
                ...globals.node,
                ...globals.es2021,
                browser: true,
                es2021: true,
            },
            parserOptions: {
                project: './tsconfig.json',
                semi: ['error', 'always'],
            },
        },
        ignores: ['src/client/*', 'node_modules/*'],
        plugins: {
            react,
            tailwindcss,
            simpleImportSort,
        },

        rules: {
            ...js.configs.recommended.rules,
            ...tseslint.configs.recommended.rules,
            'tailwindcss/classnames-order': 'warn',
            'tailwindcss/no-custom-classname': [
                'off',
                {
                    callees: ['twMerge'],
                    cssFiles: [],
                },
            ],
            semi: ['error', 'always'],
            'prefer-const': 'error',

            'no-console': 'warn',
            'no-unused-vars': 'warn',
            'simpleImportSort/imports': 'error',
            'simpleImportSort/exports': 'error',
            '@typescript-eslint/unbound-method': 'warn',

            '@typescript-eslint/no-unused-vars': [
                'warn',
                { vars: 'all', args: 'after-used', ignoreRestSiblings: false },
            ],
            '@typescript-eslint/no-misused-promises': 'off',
            'react-hooks/rules-of-hooks': 'error',
            'react-hooks/exhaustive-deps': 'warn',
        },
    },
    prettier,
]
