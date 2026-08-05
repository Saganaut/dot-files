/** @type {import('tailwindcss').Config} */
import typography from '@tailwindcss/typography'
import type { PluginUtils } from 'tailwindcss/types/config'

export default {
    darkMode: 'class',
    content: [
        './src/pages/**/*.{js,jsx,ts,tsx}',
        './src/common/**/*.{js,jsx,ts,tsx}',
    ],
    theme: {
        extend: {
            display: ['responsive'], // Moved from inner extend to here
            colors: {
                'electric-violet': {
                    DEFAULT: '#6019FF',
                    200: '#BC8BFB',
                    500: '#9F96FF',
                    700: '#9747FF',
                    900: '#4E26A5',
                },
                'blaze-orange': {
                    DEFAULT: '#FF6E0B',
                    100: '#FFBD66',
                    900: '#D45400',
                },
                'mariana-blue': {
                    DEFAULT: '#260078',
                    100: '#3821AA',
                },
                tolopea: {
                    DEFAULT: '#190042',
                },
                aquamarine: {
                    DEFAULT: '#54FFF1',
                    100: '#B0FFF8',
                    900: '#5AE6DA',
                },
                shell: {
                    DEFAULT: '#F2F2F2',
                },
                'black-white': {
                    DEFAULT: '#FFFFFD',
                },
                'black-russian': {
                    DEFAULT: '#13002A',
                },
            },

            typography: ({ theme }: PluginUtils) => ({
                DEFAULT: {
                    css: {
                        '--tw-prose-body': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-headings': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-lead': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-links': theme(
                            'colors.mariana-blue.DEFAULT'
                        ),
                        '--tw-prose-bold': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-counters': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-bullets': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-hr': theme('colors.tolopea.default'),
                        '--tw-prose-quotes': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-quote-borders': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-captions': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-code': theme('colors.tolopea.DEFAULT'),
                        // '--tw-prose-pre-code': theme('colors.shell.DEFAULT'),
                        // '--tw-prose-pre-bg': theme('colors.tolopea.DEFAULT'),
                        '--tw-prose-th-borders': theme(
                            'colors.electric-violet.900'
                        ),
                        '--tw-prose-td-borders': theme(
                            'colors.electric-violet.500'
                        ),
                        '--tw-prose-em': theme('colors.tolopea.DEFAULT'),
                        '--tw-prose-strong': theme('colors.tolopea.DEFAULT'),
                        '--tw-prose-blockquote': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-figure': theme(
                            'colors.black-russian.DEFAULT'
                        ),
                        '--tw-prose-figcaption': theme(
                            'colors.black-russian.DEFAULT'
                        ),

                        '.prose h1': {
                            fontSize: theme('fontSize.4xl'),
                            fontWeight: theme('fontWeight.bold'),
                        },
                        a: {
                            color: theme('colors.tolopea.DEFAULT'),
                            '&:hover': {
                                color: theme('colors.blaze-orange.DEFAULT'),
                            },
                        },

                        h1: {
                            fontSize: theme('fontSize.4xl'),
                        },
                        h2: {
                            fontSize: theme('fontSize.3xl'),
                        },
                        h3: {
                            fontSize: theme('fontSize.2xl'),
                        },
                        p: {
                            fontSize: theme('fontSize.base'),
                            lineHeight: theme('lineHeight.relaxed'),
                        },
                        ul: {
                            paddingLeft: theme('spacing.6'),
                        },
                        li: {
                            marginTop: theme('spacing.2'),
                            marginBottom: theme('spacing.2'),
                            // color: theme('colors.blaze-orange.DEFAULT'),
                        },
                        blockquote: {
                            fontStyle: 'italic',
                            paddingLeft: theme('spacing.4'),
                        },
                        pre: {
                            overflowX: 'auto',
                            maxWidth: '100%',
                        },
                        code: {
                            backgroundColor: 'transparent',
                            padding: 0,
                        },
                        // code: {
                        //     backgroundColor: theme('colors.tolopea.DEFAULT'),
                        //     color: theme('colors.shell.DEFAULT'),
                        //     padding: theme('spacing.1'),
                        //     borderRadius: theme('borderRadius.sm'),
                        // },
                        // pre: {
                        //     backgroundColor: theme('colors.tolopea.DEFAULT'),
                        //     color: theme('colors.shell.DEFAULT'),
                        //     padding: theme('spacing.4'),
                        //     borderRadius: theme('borderRadius.md'),
                        // },
                    },
                },
                dark: {
                    css: {
                        '--tw-prose-body': theme('colors.shell.DEFAULT'),
                        '--tw-prose-headings': theme('colors.shell.DEFAULT'),
                        '--tw-prose-lead': theme('colors.shell.DEFAULT'),
                        '--tw-prose-bold': theme('colors.shell.DEFAULT'),
                        '--tw-prose-counters': theme('colors.shell.DEFAULT'),
                        '--tw-prose-bullets': theme('colors.shell.DEFAULT'),
                        '--tw-prose-hr': theme('colors.shell.DEFAULT'),
                        '--tw-prose-quotes': theme('colors.shell.DEFAULT'),
                        '--tw-prose-quote-borders': theme(
                            'colors.shell.DEFAULT'
                        ),
                        '--tw-prose-captions': theme('colors.shell.DEFAULT'),
                        '--tw-prose-code': theme('colors.shell.DEFAULT'),
                        // '--tw-prose-pre-code': theme('colors.shell.DEFAULT'),
                        // '--tw-prose-pre-bg': theme(
                        //     'colors.electric-violet.DEFAULT'
                        // ),
                        '--tw-prose-th-borders': theme(
                            'colors.electric-violet.900'
                        ),
                        '--tw-prose-td-borders': theme(
                            'colors.electric-violet.500'
                        ),
                        '--tw-prose-em': theme('colors.aquamarine.100'),
                        '--tw-prose-strong': theme('colors.aquamarine.900'),
                        '--tw-prose-blockquote': theme('colors.shell.DEFAULT'),
                        '--tw-prose-figure': theme('colors.shell.DEFAULT'),
                        '--tw-prose-figcaption': theme('colors.shell.DEFAULT'),
                        a: {
                            color: theme('colors.aquamarine.DEFAULT'),
                            '&:hover': {
                                color: theme('colors.blaze-orange.DEFAULT'),
                            },
                        },

                        h1: {
                            fontSize: theme('fontSize.4xl'),
                        },
                        h2: {
                            fontSize: theme('fontSize.3xl'),
                        },
                        h3: {
                            fontSize: theme('fontSize.2xl'),
                        },
                        p: {
                            fontSize: theme('fontSize.base'),
                            lineHeight: theme('lineHeight.relaxed'),
                        },
                        ul: {
                            paddingLeft: theme('spacing.6'),
                        },
                        li: {
                            marginTop: theme('spacing.2'),
                            marginBottom: theme('spacing.2'),
                        },
                        blockquote: {
                            fontStyle: 'italic',
                            paddingLeft: theme('spacing.4'),
                        },
                        pre: {
                            overflowX: 'auto',
                            maxWidth: '100%',
                        },
                        code: {
                            backgroundColor: 'transparent',
                            padding: 0,
                        },
                        // pre: {
                        //     backgroundColor: theme('colors.tolopea.DEFAULT'),
                        //     color: theme('colors.shell.DEFAULT'),
                        //     padding: theme('spacing.4'),
                        //     borderRadius: theme('borderRadius.md'),
                        // },
                    },
                },
            }),

            dropShadow: {
                inputDropShadow: '0 1px 2px #0F172A0D',
                inputDropShadowFocus: [
                    '0 1px 2px 0px #0F172A0D',
                    '0 0 0 40px #E2E8F8',
                ],
                '4xl': [
                    '0 35px 35px rgba(0, 0, 0, 0.25)',
                    '0 45px 65px rgba(0, 0, 0, 0.15)',
                ],
            },
            boxShadow: {
                iconBoxShadowAqua: ' 0 0 0 2px #54FFF1',
            },
            backgroundImage: {
                'game-lobby': "url('/src/assets/GameLobbyBg.png')",
                playground: "url('/src/assets/PlaygroundBg.png')",
                confetti: "url('/src/assets/confeties.png')",
                'gradient-circle':
                    'linear-gradient(180deg, #6019FF 0%, #4211B0 100%)',
            },
        },
    },
    plugins: [typography],
}
