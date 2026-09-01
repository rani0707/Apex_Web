import awardsData from '@/lib/data/awards.json';
import projectsData from '@/lib/data/projects.json';
import activitiesData from '@/lib/data/activities.json';
import aboutDataRaw from '@/lib/data/about.json';
import recruitDataRaw from '@/lib/data/recruit.json';

export interface Award {
  title: string;
  organization: string;
  result: string;
  year: string;
}

export function getAwards(): Award[] {
  return (awardsData.awards ?? []) as Award[];
}

export interface Project {
  id: string;
  category: string;
  title: string;
  description: string;
  tags: string[];
  year: string;
  status: string;
  url: string;
}

export function getProjects(): Project[] {
  return (projectsData.projects ?? []) as Project[];
}

export interface Activity {
  number: string;
  title: string;
  subtitle: string;
  tags: string[];
  desc: string;
}

export function getActivities(): Activity[] {
  return (activitiesData.tracks ?? []) as Activity[];
}

export interface AboutData {
  intro: string;
  values: { title: string; desc: string }[];
}

export function getAbout(): AboutData {
  return aboutDataRaw as AboutData;
}

export interface TimelineItem {
  period: string;
  title: string;
  desc: string;
}

export interface Perk {
  label: string;
  icon: string;
  show: boolean;
}

export interface RecruitData {
  contactEmail: string;
  recruitFormUrl: string;
  isOpen: boolean;
  closedMessage: string;
  timeline: TimelineItem[];
  perks: Perk[];
}

export function getRecruit(): RecruitData {
  return recruitDataRaw as RecruitData;
}
