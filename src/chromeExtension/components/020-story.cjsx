React             = require 'react'
ReactRedux        = require 'react-redux'
timm              = require 'timm'
tinycolor         = require 'tinycolor2'
moment            = require 'moment'
ColoredText       = require './030-coloredText'
Icon              = require './910-icon'
actions           = require '../actions/actions'

mapStateToProps = ({settings: {fRelativeTime}}) -> {fRelativeTime}
mapDispatchToProps = (dispatch) ->
  onToggleRelativeTime: -> dispatch actions.toggleRelativeTime()
  onToggleExpanded: (pathStr) -> dispatch actions.toggleExpanded pathStr
  onToggleHierarchical: (pathStr) -> dispatch actions.toggleHierarchical pathStr

_Story = React.createClass
  displayName: 'Story'

  #-----------------------------------------------------
  propTypes:
    story:                  React.PropTypes.object.isRequired
    level:                  React.PropTypes.number.isRequired
    seqFullRefresh:         React.PropTypes.number.isRequired
    # From Redux.connect
    fRelativeTime:          React.PropTypes.bool.isRequired
    onToggleRelativeTime:   React.PropTypes.func.isRequired
    onToggleExpanded:       React.PropTypes.func.isRequired
    onToggleHierarchical:   React.PropTypes.func.isRequired

  ## DELETE!
  getInitialState: ->
    fHierarchical:          true
    fExpanded:              @props.story.fOpen

  #-----------------------------------------------------
  render: -> 
    if @props.story.fWrapper then return @_renderRecords()
    if @props.level is 1 then return @_renderRootStory()
    return @_renderNormalStory()

  _renderRootStory: ->
    {level, story} = @props
    <div className="rootStory" style={_style.outer level, story}>
      <div className="rootStoryTitle" style={_style.rootStoryTitle}>
        {story.title.toUpperCase()}
      </div>
      {@_renderRecords()}
    </div>

  _renderNormalStory: ->
    {level, story} = @props
    {title, fOpen} = story
    if fOpen then spinner = <Icon icon="circle-o-notch"/>
    <div className="story" style={_style.outer(level, story)}>
      <div 
        className="storyTitle" 
        style={_style.titleRow level}
      >
        {@_renderTime story}
        {@_renderIndent level-1}
        {@_renderCaretOrSpace true}
        <ColoredText 
          text={title} 
          onClick={@_toggleExpanded}
          style={_style.title}
        />
        {spinner}
      </div>
      {@_renderRecords()}
    </div>

  _renderRecords: ->
    return if not @state.fExpanded
    records = @props.story.records
    <div>{records.map @_renderRecord}</div>

  _renderRecord: (record, idx) ->
    {id, storyId, msg, fServer} = record
    if record.fStory 
      return <Story key={id} 
        story={record} 
        level={@props.level + 1}
        seqFullRefresh={@props.seqFullRefresh}
      />
    level = @props.level
    <div key={id} 
      className="log"
      style={_style.log level}
    >
      {@_renderTime record}
      {@_renderIndent level}
      {@_renderCaretOrSpace false}
      <ColoredText text={msg}/>
    </div>

  _renderTime: (record) ->
    {fStory, t} = record
    {level, fRelativeTime} = @props
    if fRelativeTime
      relTime = moment(t).fromNow()
    if (fStory and level <= 2) or (level <= 1)
      absTime = moment(t).format('YYYY-MM-DD HH:mm:ss.SSS')
    else
      absTime = '           ' + moment(t).format('HH:mm:ss.SSS')
    <span 
      onClick={@props.onToggleRelativeTime}
      style={_style.time fRelativeTime}
      title={if fRelativeTime then absTime}
    >
      {if fRelativeTime then relTime else absTime}
    </span>

  _renderIndent: (level) -> <div style={_style.indent level}/>
  _renderCaretOrSpace: (fCaret) ->
    if fCaret
      iconType = if @state.fExpanded then 'caret-down' else 'caret-right'
      icon = <Icon icon={iconType} onClick={@_toggleExpanded}/>
    <span style={_style.caretOrSpace}>
      {icon}
    </span>

  #-----------------------------------------------------
  _toggleExpanded: -> @props.onToggleExpanded @props.story.pathStr

#-----------------------------------------------------
_style = 
  outer: (level, story) ->
    bgColor = 'aliceblue'
    if story.fServer then bgColor = tinycolor(bgColor).darken(5).toHexString()
    backgroundColor: bgColor # if story.fServer then '#f5f5f5' else '#e8e8e8'
    marginBottom: if level <= 1 then 10
    padding: if level <= 1 then 2
  rootStoryTitle:
    fontWeight: 900
    textAlign: 'center'
    letterSpacing: 3
    marginBottom: 5
  titleRow: (level) ->
    fontWeight: 900
    fontFamily: 'monospace'
    whiteSpace: 'pre'
  title:
    cursor: 'pointer'
  log: (level) ->
    fontFamily: 'monospace'
    whiteSpace: 'pre'
  time: (fRelativeTime) ->
    display: 'inline-block'
    width: 170
    cursor: 'pointer'
    fontStyle: if fRelativeTime then 'italic'
  indent: (level) ->
    display: 'inline-block'
    width: 20 * (level - 1)
  caretOrSpace:
    display: 'inline-block'
    width: 30
    paddingLeft: 10
    cursor: 'pointer'

#-----------------------------------------------------
connect = ReactRedux.connect mapStateToProps, mapDispatchToProps
Story = connect _Story
module.exports = Story