<script lang="ts">
  let otp_generated: boolean = $state(false);
  let email: string = $state("");
  function submit() {}
  async function genrate_otp() {
    let out = await fetch("http://127.0.0.1:3000/user/otp", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email: email }),
    });
    if (out.ok) {
      otp_generated = true;
      alert("otp generated!");
    }
  }
</script>

<h1>Register new user</h1>
<form onsubmit={genrate_otp}>
  <input type="email" bind:value={email} />
  <input type="submit" value="Generate otp" />
</form>

{#if otp_generated}
  <form onsubmit={submit}>
    <input type="number" />
    <input type="submit" value="enter otp" />
  </form>
{/if}
<a href="/auth/login">Already Have Accout? Log in</a>
