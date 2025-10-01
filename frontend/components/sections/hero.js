export default function Hero({ heading, subheading }) {
  return (
    <header style={{padding: '4rem 2rem', textAlign: 'center'}}>
      <h1>{heading}</h1>
      <p>{subheading}</p>
    </header>
  )
}
