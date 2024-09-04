import globals from 'globals'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import js from '@eslint/js'
import { FlatCompat } from '@eslint/eslintrc'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all,
})

export default [
    {
        ignores: ['node_modules/'],
    },
    ...compat.extends('eslint:recommended', 'google'),
    {
        plugins: {},

        languageOptions: {
            globals: {
                ...globals.node,
            },

            ecmaVersion: 8,
            sourceType: 'commonjs',

            parserOptions: {
                ecmaFeatures: {
                    impliedStrict: true,
                },
            },
        },

        rules: {
            'arrow-parens': ['error', 'as-needed'],

            camelcase: [
                'error',
                {
                    properties: 'always',
                },
            ],

            'comma-dangle': [
                'error',
                {
                    arrays: 'never',
                    objects: 'never',
                    imports: 'never',
                    exports: 'never',
                    functions: 'never',
                },
            ],

            curly: ['error', 'all'],
            eqeqeq: ['error', 'always'],
            'generator-star-spacing': ['error', 'before'],
            'guard-for-in': ['error'],

            indent: [
                'error',
                4,
                {
                    SwitchCase: 1,
                },
            ],

            'key-spacing': [
                'error',
                {
                    mode: 'minimum',
                },
            ],

            'linebreak-style': ['error', 'unix'],

            'max-len': [
                'error',
                120,
                4,
                {
                    ignoreComments: true,
                    ignoreUrls: true,
                    ignoreTrailingComments: true,
                },
            ],

            'new-cap': [
                'error',
                {
                    properties: false,
                },
            ],

            'no-console': ['off'],
            'no-else-return': ['error'],
            'no-extra-boolean-cast': ['off'],
            'no-floating-decimal': ['off'],

            'no-implicit-coercion': [
                'error',
                {
                    boolean: false,
                    number: false,
                    string: false,
                },
            ],

            'no-invalid-this': ['warn'],
            'no-throw-literal': ['off'],

            'no-trailing-spaces': [
                'warn',
                {
                    skipBlankLines: true,
                },
            ],

            'no-undefined': ['error'],

            'no-unused-vars': [
                'error',
                {
                    args: 'none',
                },
            ],

            'no-useless-return': ['error'],
            'no-var': ['warn'],

            quotes: [
                'error',
                'single',
                {
                    allowTemplateLiterals: true,
                },
            ],

            'quote-props': ['error', 'as-needed'],

            'require-jsdoc': [
                'error',
                {
                    require: {
                        FunctionDeclaration: true,
                        MethodDefinition: true,
                        ClassDeclaration: true,
                        ArrowFunctionExpression: false,
                    },
                },
            ],

            'space-before-function-parent': [
                'error',
                {
                    anonymous: 'never',
                    named: 'never',
                    asyncArrow: 'always',
                },
            ],

            'valid-jsdoc': [
                'error',
                {
                    requireReturn: false,
                },
            ],
        },
    },
]
