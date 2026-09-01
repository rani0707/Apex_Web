import Navbar from '@/components/Navbar';
import Hero from '@/components/Hero';
import About from '@/components/About';
import Activities from '@/components/Activities';
import Projects from '@/components/Projects';
import Awards from '@/components/Awards';
import Recruit from '@/components/Recruit';
import Footer from '@/components/Footer';
import {
  getAwards,
  getProjects,
  getActivities,
  getAbout,
  getRecruit,
} from '@/lib/fetchers';

export default function Home() {
  const awardsData = getAwards();
  const projectsData = getProjects();
  const activitiesData = getActivities();
  const aboutData = getAbout();
  const recruitData = getRecruit();

  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <About intro={aboutData.intro} values={aboutData.values} />
        <Activities tracks={activitiesData} />
        <Projects projects={projectsData} />
        <Awards awards={awardsData} />
        <Recruit
          timeline={recruitData.timeline}
          perks={recruitData.perks}
          isOpen={recruitData.isOpen}
          closedMessage={recruitData.closedMessage}
          recruitFormUrl={recruitData.recruitFormUrl}
        />
      </main>
      <Footer contactEmail={recruitData.contactEmail} />
    </>
  );
}
