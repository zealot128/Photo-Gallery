<script>
  export let from
  export let to
  import ExpansionPanel from "rewrite/lib/ForkedExpansionPanel"
  import { Textfield } from 'svelte-mui'

  const today = new Date()

  let maxFrom = today
  let minTo = null

  $: if (from) {
    minTo = from
  } else {
    minTo = null
  }
  $: if (to) {
    maxFrom = to
  } else {
    maxFrom = today
  }

  const format = (stringOrDate) => {
    if (stringOrDate && stringOrDate.toISOString) {
      return stringOrDate.toISOString().split('T')[0]
    } else {
      return stringOrDate
    }
  }

</script>


<ExpansionPanel name="Date" group="">
  <div>
    <Textfield bind:value={from} type='date' label='From' max={format(maxFrom)} />
    <Textfield bind:value={to} type='date' label='To' min={format(minTo)} max={format(today)} />
  </div>
</ExpansionPanel>


