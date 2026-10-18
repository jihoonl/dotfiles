import type { Register } from 'claude-code'

// A leading `---` block would draw as a rule and a setext heading.
const FRONTMATTER = /^---\n([\s\S]*?)\n---\n/

export const register: Register = on => {
  on('ui.render', { component: 'ToolResult', props: { tool: 'Write' } }, ($, e, next) => {
    const out = e.props.output as { filePath: string; content: string }
    if (e.props.isErrored || !out.filePath.endsWith('.md')) {
      return next(e)
    }
    const { Markdown } = $.ui.resolve(e)
    return <Markdown text={out.content.replace(FRONTMATTER, '```yaml\n$1\n```\n')} />
  })
}
