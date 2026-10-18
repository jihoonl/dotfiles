import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'

const SURFACES = ['terminal', 'desktop'] as const

function write(filePath: string, content: string, isErrored = false) {
  return {
    plugin: 'md-render',
    component: 'ToolResult',
    props: {
      tool_use_id: 'toolu_1',
      tool: 'Write',
      output: { type: 'create', filePath, content, structuredPatch: [], originalFile: null },
      isErrored,
    },
  } as const
}

async function drawnMarkdown($: Engine, target: ReturnType<typeof write>) {
  const texts: (string | undefined)[] = []
  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...target, surface })
    texts.push((await ui.find({ type: 'Markdown' }))?.text)
    await ui.unmount()
  }
  return texts
}

test('a .md write draws as markdown', async $ => {
  const md = '# Spec\n\n| a | b |\n|---|---|\n| 1 | 2 |\n'
  expect(await drawnMarkdown($, write('/r/docs/x/spec.md', md))).toEqual([md, md])
})

test('frontmatter draws as a yaml block', async $ => {
  const md = '---\nissue: 12\nupdated: 2026-10-18\n---\n# Plan\n'
  const want = '```yaml\nissue: 12\nupdated: 2026-10-18\n```\n# Plan\n'
  expect(await drawnMarkdown($, write('/r/docs/x/plan.md', md))).toEqual([want, want])
})

test('other writes keep the engine row', async ($, on) => {
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>engine row</Text>
  })
  expect(await drawnMarkdown($, write('/r/a.py', 'x = 1\n'))).toEqual([undefined, undefined])
  expect(await drawnMarkdown($, write('/r/spec.md', '# x\n', true))).toEqual([undefined, undefined])
})
